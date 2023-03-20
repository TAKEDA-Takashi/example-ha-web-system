'use strict';

const os = require('os');
const express = require('express');

function getIpAddress() {
  const nifs = os.networkInterfaces();
  const net0 = nifs['eth0']?.find((v) => v.family === 'IPv4');
  const net1 = nifs['eth1']?.find((v) => v.family === 'IPv4');

  return !!net1 ? net1?.address : net0?.address;
}

const host = getIpAddress();

const HOST = '0.0.0.0';
const PORT = 3000;

const app = express();

app.get('/hello', (req, res) => {
  res.send(`Hello World. ${host}`);
});

app.listen(PORT, HOST, () => {
  console.log(`Running app. port:${PORT}`);
});
