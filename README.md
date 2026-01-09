# Grupo Ríos Tampico - Sitio Web

Página web profesional para Grupo Ríos Tampico, lista para desplegar en hosting Linux con cPanel.

## 📁 Estructura del Proyecto

```
grupo-rios-tampico/
│
├── index.html              # Página principal
├── styles.css              # Estilos y diseño responsive
├── script.js               # Funcionalidad JavaScript
├── .htaccess              # Configuración del servidor Apache
├── DEPLOYMENT-GUIDE.md    # Guía completa de despliegue
└── README.md              # Este archivo
```

## 🌟 Características

- ✅ Diseño moderno y profesional
- ✅ 100% Responsive (móvil, tablet, escritorio)
- ✅ Navegación suave y animaciones
- ✅ Formulario de contacto funcional
- ✅ Optimizado para SEO
- ✅ Configuración de seguridad incluida
- ✅ Compatibilidad con todos los navegadores modernos

## 🚀 Despliegue Rápido

### Archivos a subir a tu hosting:

1. `index.html`
2. `styles.css`
3. `script.js`
4. `.htaccess`

### Pasos básicos:

1. Accede a cPanel en GoDaddy
2. Ve al Administrador de Archivos
3. Navega a la carpeta `public_html`
4. Sube todos los archivos
5. ¡Listo! Tu sitio estará funcionando

📖 **Para instrucciones detalladas, consulta [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)**

## ✏️ Personalización

### Modificar información de contacto:

Edita [index.html](index.html) en las siguientes secciones:
- **Dirección**: Línea 159
- **Teléfono**: Línea 170
- **Email**: Línea 181

### Cambiar colores:

Edita [styles.css](styles.css) líneas 2-9:
```css
--primary-color: #0066cc;    /* Color principal */
--secondary-color: #004999;  /* Color secundario */
--accent-color: #ff6b35;     /* Color de acento */
```

### Modificar servicios:

Edita [index.html](index.html) líneas 55-90 con tus servicios específicos.

## 🔒 Seguridad

El archivo `.htaccess` incluye:
- Protección contra listado de directorios
- Headers de seguridad (XSS, MIME sniffing, clickjacking)
- Configuración para SSL/HTTPS
- Caché optimizado para mejor rendimiento

## 📧 Configurar el Formulario

El formulario requiere configuración adicional. Ver opciones en [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md):
- Opción 1: Servicios externos (FormSpree, EmailJS)
- Opción 2: Script PHP personalizado

## 🌐 Navegadores Soportados

- ✅ Chrome (últimas 2 versiones)
- ✅ Firefox (últimas 2 versiones)
- ✅ Safari (últimas 2 versiones)
- ✅ Edge (últimas 2 versiones)
- ✅ Mobile browsers (iOS Safari, Chrome Mobile)

## 📱 Pruebas

Antes de subir a producción, prueba:
- [ ] Vista en móvil
- [ ] Vista en tablet
- [ ] Vista en escritorio
- [ ] Navegación del menú
- [ ] Formulario de contacto
- [ ] Enlaces internos

## 🆘 Soporte

Para problemas con el hosting, contacta:
- Soporte GoDaddy: https://www.godaddy.com/help

## 📄 Licencia

Este proyecto está creado para uso de Grupo Ríos Tampico.

## 🎉 ¡Todo listo!

Tu sitio web profesional está preparado para subir a tu hosting de GoDaddy. Sigue la guía de despliegue y tendrás tu página en línea en minutos.

**¡Éxito con tu proyecto!**
