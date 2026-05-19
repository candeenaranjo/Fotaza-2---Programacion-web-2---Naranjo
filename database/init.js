require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function inicializarBD() {
  const client = new Client({
    host:     process.env.DB_HOST,
    user:     process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port:     process.env.DB_PORT || 5432
  });

  await client.connect();
  console.log('Creando tablas...');

  const sql = fs.readFileSync(
    path.join(__dirname, 'init.sql'), 'utf8'
  );

  await client.query(sql);
  console.log('Base de datos inicializada correctamente.');
  await client.end();
}

inicializarBD().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});