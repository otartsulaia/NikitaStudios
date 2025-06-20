const apiBase = 'https://api.mail.tm';
const accounts = [];
let currentAccountIndex = null;

async function getDomains() {
  const res = await fetch(`${apiBase}/domains`);
  const data = await res.json();
  return data['hydra:member'][0].domain;
}

function randomString(len) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let str = '';
  for (let i = 0; i < len; i++) {
    str += chars[Math.floor(Math.random() * chars.length)];
  }
  return str;
}

async function generateAccount() {
  const domain = await getDomains();
  const address = `${randomString(10)}@${domain}`;
  const password = randomString(12);

  const res = await fetch(`${apiBase}/accounts`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ address, password })
  });
  if (!res.ok) {
    alert('Failed to create account');
    return;
  }

  accounts.push({ address, password });
  updateAccountList();
}

async function getToken(account) {
  const res = await fetch(`${apiBase}/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ address: account.address, password: account.password })
  });
  if (!res.ok) return null;
  const data = await res.json();
  return data.token;
}

function updateAccountList() {
  const list = document.getElementById('accountList');
  list.innerHTML = '';
  accounts.forEach((acc, idx) => {
    const li = document.createElement('li');
    li.textContent = acc.address;
    li.addEventListener('click', () => selectAccount(idx));
    list.appendChild(li);
  });
}

async function selectAccount(idx) {
  currentAccountIndex = idx;
  const acc = accounts[idx];
  document.getElementById('currentAccount').textContent = acc.address;
  document.getElementById('credentials').textContent = `Password: ${acc.password}`;
  document.getElementById('listEmails').disabled = false;
  document.getElementById('mailList').innerHTML = '';
  document.getElementById('mailDetail').innerHTML = '';
}

async function listEmails() {
  if (currentAccountIndex === null) return;
  const acc = accounts[currentAccountIndex];
  const token = await getToken(acc);
  if (!token) { alert('Login failed'); return; }
  const res = await fetch(`${apiBase}/messages`, {
    headers: { Authorization: `Bearer ${token}` }
  });
  const data = await res.json();
  const ul = document.createElement('ul');
  data['hydra:member'].forEach(msg => {
    const li = document.createElement('li');
    li.textContent = `${msg.from.address} - ${msg.subject}`;
    li.addEventListener('click', () => showEmail(msg.id, token));
    ul.appendChild(li);
  });
  const container = document.getElementById('mailList');
  container.innerHTML = '';
  container.appendChild(ul);
}

async function showEmail(id, token) {
  const res = await fetch(`${apiBase}/messages/${id}`, {
    headers: { Authorization: `Bearer ${token}` }
  });
  const msg = await res.json();
  const detail = document.getElementById('mailDetail');
  detail.innerHTML = `<h3>${msg.subject}</h3><p>From: ${msg.from.address}</p><p>${msg.text}</p>`;
}

function importAccounts(event) {
  const file = event.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = e => {
    try {
      const imported = JSON.parse(e.target.result);
      imported.forEach(acc => accounts.push(acc));
      updateAccountList();
    } catch (err) {
      alert('Invalid file');
    }
  };
  reader.readAsText(file);
}

document.getElementById('generate').addEventListener('click', generateAccount);
document.getElementById('listEmails').addEventListener('click', listEmails);
document.getElementById('import').addEventListener('click', () => document.getElementById('importFile').click());
document.getElementById('importFile').addEventListener('change', importAccounts);
document.getElementById('export').addEventListener('click', exportAccounts);

function exportAccounts() {
  const data = JSON.stringify(accounts);
  const blob = new Blob([data], { type: 'application/json' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'accounts.json';
  a.click();
}
