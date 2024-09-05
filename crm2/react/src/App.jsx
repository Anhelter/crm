import ReactDOM from "react-dom/client";
import React, { useEffect } from 'react';
import { BrowserRouter, Routes, Route, useLocation } from "react-router-dom";
import Layout from "./components/Layout";
import LoginPage from './pages/LoginPage'; // El componente de la página de inicio de sesión
import Dashboard from './pages/Dashboard';
import Home from "./components/Home";
import PostUser from "./components/PostUser";
import GetAllUser from "./components/GetAllUser";
import './css/style.css';
import './charts/ChartjsConfig';

function App() {
  const location = useLocation();

  useEffect(() => {
    document.querySelector('html').style.scrollBehavior = 'auto'
    window.scroll({ top: 0 })
    document.querySelector('html').style.scrollBehavior = ''
  }, [location.pathname]); // triggered on route change
  return (
    <>
      <Routes>
      {/* Ruta para la pantalla de login */}
      <Route exact path="/" element={<LoginPage />} />

      {/* Ruta para el Dashboard */}
      <Route path="/dashboard" element={<Dashboard />} />

      {/* Otras rutas de la aplicación */}
      <Route path="/home" element={<Home />} />
      <Route path="/post" element={<PostUser />} />
      <Route path="/get" element={<GetAllUser />} />
    </Routes>
    </>
  );
}

export default App;
//const root = ReactDOM.createRoot(document.getElementById('root'));
//root.render(<App />);
//<Route index element={<LoginPage />} />