import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();

  const handleLogin = async () => {
    try {
      const response = await axios.post('/api/login', {
        email,
        password,
      });

      if (response.data.success) {
        localStorage.setItem('authToken', response.data.token);
        navigate('dashboard');
      } else {
        alert('Usuario o contraseña incorrectos');
      }
    } catch (error) {
      console.error('Error durante el inicio de sesión:', error);
      alert('Ocurrió un error durante el inicio de sesión.');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-dark">
      <div className="w-full max-w-md p-8 space-y-8 bg-gray-200 shadow-md rounded-lg">
        <div className="flex justify-center">
          <a href="#">
            <img src="../src/images/favicon.png" alt="logo" className="w-32" />
          </a>
        </div>
        <h4 className="text-center text-2xl font-semibold mt-4 mb-6">Iniciar Sesión</h4>
        <div className="space-y-4">
          <div className="form-group">
            <input
              type="email"
              className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              id="floatingInput"
              placeholder="Correo Electrónico"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div className="form-group">
            <input
              type="password"
              className="w-full px-4 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              id="floatingInput1"
              placeholder="Contraseña"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
        </div>
        <div className="flex items-center justify-between mt-4">
          <div className="flex items-center">
            <input
              className="form-check-input h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              type="checkbox"
              id="customCheckc1"
              defaultChecked
            />
            <label
              className="ml-2 block text-gray-700 text-sm"
              htmlFor="customCheckc1"
            >
              Recuérdame
            </label>
          </div>
          <h6 className="text-sm text-blue-600 cursor-pointer">¿Olvidaste tu contraseña?</h6>
        </div>
        <div className="text-center mt-6">
          <button
            type="button"
            className="w-full py-2 px-4 bg-blue-600 text-white font-semibold rounded-md shadow hover:bg-blue-700 transition duration-200"
            onClick={()=> navigate('/dashboard')}>
            Iniciar Sesión
          </button>
        </div>
        <div className="flex justify-between items-center mt-6">
          <h6 className="text-sm font-medium text-gray-700">¿No tienes una cuenta?</h6>
          <a href="#" className="text-blue-600 text-sm font-medium hover:underline">
            Crear Cuenta
          </a>
        </div>
      </div>
    </div>
  );
}

export default LoginPage;
