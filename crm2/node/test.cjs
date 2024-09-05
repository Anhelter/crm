const { Client } = require('pg');

const client = new Client({
  host: 'db',          // Nombre del servicio en docker-compose
  user: 'postgres',    // Usuario de PostgreSQL
  password: '1234',    // Contraseña de PostgreSQL
  database: 'postgres',// Base de datos de PostgreSQL
  port: 5432,          // Puerto de PostgreSQL
});

client.connect()
  .then(() => {
    console.log('Conectado a la base de datos');
    client.end(); // Cerrar la conexión
  })
  .catch(err => console.error('Error de conexión', err.stack));
