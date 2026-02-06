import SpriteKit

final class RunnerScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Categories
    private let playerCategory: UInt32 = 0x1
    private let obstacleCategory: UInt32 = 0x2
    private let coinCategory: UInt32 = 0x4
    private let groundCategory: UInt32 = 0x8

    // MARK: - Nodes
    private var player: SKSpriteNode!
    private var ground1: SKSpriteNode!
    private var ground2: SKSpriteNode!

    // MARK: - State
    private var lanes: [CGFloat] = []
    private var currentLane = 1
    private var isJumping = false
    private var gameSpeed: CGFloat = 4.0
    private var spawnTimer: TimeInterval = 0
    private var scoreTimer: TimeInterval = 0
    private var isRunning = false

    var onScoreChanged: ((Int) -> Void)?
    var onCoinsChanged: ((Int) -> Void)?
    var onGameOver: (() -> Void)?

    private var currentScore = 0
    private var currentCoins = 0

    // MARK: - Setup

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        physicsWorld.gravity = CGVector(dx: 0, dy: -20)
        physicsWorld.contactDelegate = self

        setupLanes()
        setupGround()
        setupPlayer()
        isRunning = true

        // Gesture recognizers
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeUp)
    }

    private func setupLanes() {
        let laneWidth = size.width / 3
        lanes = [
            laneWidth * 0.5,
            laneWidth * 1.5,
            laneWidth * 2.5
        ]
    }

    private func setupGround() {
        let groundHeight: CGFloat = 3
        let groundY: CGFloat = size.height * 0.2

        ground1 = SKSpriteNode(color: .systemGray3, size: CGSize(width: size.width, height: groundHeight))
        ground1.position = CGPoint(x: size.width / 2, y: groundY)
        ground1.zPosition = 1
        addChild(ground1)

        // Lane dividers
        for lane in lanes {
            let divider = SKSpriteNode(color: .systemGray5, size: CGSize(width: 1, height: size.height))
            divider.position = CGPoint(x: lane, y: size.height / 2)
            divider.zPosition = 0
            divider.alpha = 0.3
            addChild(divider)
        }

        // Ground physics
        let groundBody = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: 2))
        groundBody.position = CGPoint(x: size.width / 2, y: groundY - 10)
        groundBody.physicsBody = SKPhysicsBody(rectangleOf: groundBody.size)
        groundBody.physicsBody?.isDynamic = false
        groundBody.physicsBody?.categoryBitMask = groundCategory
        addChild(groundBody)
    }

    private func setupPlayer() {
        let playerSize = CGSize(width: 30, height: 45)
        player = SKSpriteNode(color: .systemGreen, size: playerSize)
        player.position = CGPoint(x: lanes[currentLane], y: size.height * 0.2 + 25)
        player.zPosition = 10

        player.physicsBody = SKPhysicsBody(rectangleOf: playerSize)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = obstacleCategory | coinCategory
        player.physicsBody?.collisionBitMask = groundCategory
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0

        // Add a "head"
        let head = SKShapeNode(circleOfRadius: 10)
        head.fillColor = .systemGreen
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: playerSize.height / 2 + 5)
        player.addChild(head)

        addChild(player)
    }

    // MARK: - Gestures

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard isRunning else { return }

        switch gesture.direction {
        case .left:
            if currentLane > 0 {
                currentLane -= 1
                movePlayerToLane()
            }
        case .right:
            if currentLane < 2 {
                currentLane += 1
                movePlayerToLane()
            }
        case .up:
            jump()
        default:
            break
        }
    }

    private func movePlayerToLane() {
        let action = SKAction.moveTo(x: lanes[currentLane], duration: 0.15)
        action.timingMode = .easeOut
        player.run(action)
    }

    private func jump() {
        guard !isJumping else { return }
        isJumping = true
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 55))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.isJumping = false
        }
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        guard isRunning else { return }

        // Spawn obstacles
        spawnTimer += 1.0 / 60.0
        if spawnTimer > max(0.8, 2.0 - Double(gameSpeed) * 0.1) {
            spawnTimer = 0
            spawnObstacleOrCoin()
        }

        // Score
        scoreTimer += 1.0 / 60.0
        if scoreTimer > 0.1 {
            scoreTimer = 0
            currentScore += 1
            onScoreChanged?(currentScore)
        }

        // Move obstacles
        enumerateChildNodes(withName: "obstacle") { node, _ in
            node.position.y -= self.gameSpeed
            if node.position.y < -50 {
                node.removeFromParent()
            }
        }

        enumerateChildNodes(withName: "coin") { node, _ in
            node.position.y -= self.gameSpeed
            if node.position.y < -50 {
                node.removeFromParent()
            }
        }

        // Speed up gradually
        gameSpeed = min(12, 4.0 + CGFloat(currentScore) / 200.0)
    }

    // MARK: - Spawning

    private func spawnObstacleOrCoin() {
        let lane = Int.random(in: 0...2)

        if Int.random(in: 0...4) == 0 {
            spawnCoin(lane: lane)
        } else {
            spawnObstacle(lane: lane)
        }
    }

    private func spawnObstacle(lane: Int) {
        let obstacleTypes: [(CGSize, UIColor)] = [
            (CGSize(width: 40, height: 40), .systemRed),
            (CGSize(width: 50, height: 25), .systemOrange),
            (CGSize(width: 30, height: 55), .systemRed),
        ]

        let type = obstacleTypes.randomElement()!
        let obstacle = SKSpriteNode(color: type.1, size: type.0)
        obstacle.position = CGPoint(x: lanes[lane], y: size.height + 50)
        obstacle.name = "obstacle"
        obstacle.zPosition = 5

        obstacle.physicsBody = SKPhysicsBody(rectangleOf: type.0)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = playerCategory

        addChild(obstacle)
    }

    private func spawnCoin(lane: Int) {
        let coin = SKShapeNode(circleOfRadius: 10)
        coin.fillColor = .systemYellow
        coin.strokeColor = .orange
        coin.lineWidth = 2
        coin.position = CGPoint(x: lanes[lane], y: size.height + 50)
        coin.name = "coin"
        coin.zPosition = 5

        coin.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = playerCategory

        // Spin animation
        coin.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 1.0)))

        addChild(coin)
    }

    // MARK: - Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        let bodies = [contact.bodyA, contact.bodyB]
        let categories = bodies.map { $0.categoryBitMask }

        if categories.contains(obstacleCategory) && categories.contains(playerCategory) {
            gameOver()
        }

        if categories.contains(coinCategory) && categories.contains(playerCategory) {
            let coinBody = bodies.first { $0.categoryBitMask == coinCategory }
            coinBody?.node?.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.5, duration: 0.1),
                    SKAction.fadeOut(withDuration: 0.1)
                ]),
                SKAction.removeFromParent()
            ]))
            currentCoins += 1
            onCoinsChanged?(currentCoins)
        }
    }

    // MARK: - Game Over

    private func gameOver() {
        isRunning = false

        // Flash player
        player.run(SKAction.repeat(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: 0.1),
                SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            ]),
            count: 3
        ))

        onGameOver?()
    }

    func restart() {
        // Remove obstacles and coins
        enumerateChildNodes(withName: "obstacle") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "coin") { node, _ in node.removeFromParent() }

        // Reset player
        currentLane = 1
        player.position = CGPoint(x: lanes[currentLane], y: size.height * 0.2 + 25)
        player.physicsBody?.velocity = .zero
        player.alpha = 1.0

        // Reset state
        currentScore = 0
        currentCoins = 0
        gameSpeed = 4.0
        spawnTimer = 0
        scoreTimer = 0
        isJumping = false
        isRunning = true

        onScoreChanged?(0)
        onCoinsChanged?(0)
    }
}
