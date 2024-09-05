import pg from 'pg';
import express from 'express';

const { Client } = pg;

// Configuración de la conexión a PostgreSQL
const client = new Client({
  user: 'postgres',
  host: 'db1',           // Nombre del servicio de PostgreSQL en Docker Compose
  database: 'erpapp', // Nombre de la base de datos
  password: '1234',     // Contraseña de PostgreSQL
  port: 5432,           // Puerto en el que PostgreSQL está escuchando
});

// Función para conectar a la base de datos
const connectDB = async () => {
  try {
    await client.connect();
    console.log('Conectado a la base de datos');
  } catch (err) {
    console.error('Error de conexión a la base de datos', err.stack);
    process.exit(1); // Salir si no se puede conectar a la base de datos
  }
};


// Inicializa Express y configura middleware
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Ruta de prueba
app.get('/api', (req, res) => res.send('Hello World!'));

// Ruta para obtener todos los usuarios
app.get('/api/all', async (req, res) => {
  try {
    const response = await client.query('SELECT * FROM auth_usuarios');
    res.status(200).send(response.rows);
  } catch (error) {
    console.error('Error al obtener usuarios', error.stack);
    res.status(500).send('Error al obtener usuarios');
  }
});

// Ruta para agregar un nuevo usuario
app.post('/api/form', async (req, res) => {
  const { name, email, age } = req.body;
  try {
    const response = await client.query(
      'INSERT INTO auth_usuarios(name, email, age) VALUES ($1, $2, $3) RETURNING *',
      [name, email, age]
    );
    res.status(201).send(response.rows[0]);
  } catch (error) {
    console.error('Error al insertar usuario', error.stack);
    res.status(500).send('Error al insertar usuario');
  }
});

// Inicia el servidor solo después de conectar a la base de datos y crear la tabla
const startServer = async () => {
  await connectDB();
  //await createTable();

  app.listen(3000,'0.0.0.0', () => {
    console.log('App running on port 3000.');
  });
};

// Manejar señales de terminación para cerrar la conexión a la base de datos
process.on('SIGTERM', async () => {
  try {
    await client.end();
    console.log('Conexión a la base de datos cerrada');
  } catch (err) {
    console.error('Error cerrando la conexión a la base de datos', err.stack);
  } finally {
    process.exit(0);
  }
});

// Iniciar el servidor
startServer();
