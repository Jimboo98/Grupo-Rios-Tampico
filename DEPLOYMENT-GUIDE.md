# Guía de Despliegue - Grupo Ríos Tampico
## Cómo subir tu página web a GoDaddy con cPanel

### 📋 Archivos a subir

Tu sitio web incluye los siguientes archivos:
- `index.html` - Página principal
- `styles.css` - Estilos
- `script.js` - Funcionalidad JavaScript
- `.htaccess` - Configuración del servidor

---

## 🚀 Pasos para subir tu sitio a GoDaddy

### Método 1: Usando el Administrador de Archivos de cPanel (Recomendado)

#### Paso 1: Acceder a cPanel
1. Ve a tu panel de GoDaddy (https://www.godaddy.com)
2. Inicia sesión con tu cuenta
3. Ve a "Mis Productos" → "Hosting Web"
4. Haz clic en "Administrar" junto a tu plan de hosting
5. Busca y haz clic en "Administrador de archivos" o "cPanel"

#### Paso 2: Navegar al directorio correcto
1. En cPanel, haz clic en "Administrador de archivos" (File Manager)
2. Navega a la carpeta `public_html` (esta es la carpeta raíz de tu sitio web)
3. **IMPORTANTE:** Elimina cualquier archivo `index.html` o `index.php` que ya exista

#### Paso 3: Subir los archivos
1. Haz clic en el botón "Cargar" (Upload) en la parte superior
2. Selecciona los siguientes archivos desde tu computadora:
   - `index.html`
   - `styles.css`
   - `script.js`
   - `.htaccess`
3. Espera a que se complete la carga (verás una barra de progreso)
4. Cierra la ventana de carga cuando termine

#### Paso 4: Verificar permisos
1. Regresa al Administrador de archivos
2. Selecciona el archivo `index.html`
3. Haz clic derecho → "Permisos" (Permissions)
4. Asegúrate que tenga permisos 644 (está bien si ya está así)
5. Haz lo mismo con los demás archivos

#### Paso 5: Probar tu sitio
1. Abre tu navegador
2. Ve a tu dominio (ejemplo: `http://tudominio.com`)
3. ¡Deberías ver tu página web funcionando!

---

### Método 2: Usando FTP (FileZilla)

#### Paso 1: Obtener credenciales FTP
1. En cPanel, busca "Cuentas FTP" (FTP Accounts)
2. Anota estos datos:
   - Servidor FTP: generalmente es `ftp.tudominio.com`
   - Usuario FTP: tu nombre de usuario
   - Contraseña: (créala si es necesario)
   - Puerto: 21

#### Paso 2: Configurar FileZilla
1. Descarga FileZilla desde https://filezilla-project.org/ (si no lo tienes)
2. Instálalo y ábrelo
3. En la parte superior ingresa:
   - Servidor: `ftp.tudominio.com`
   - Usuario: tu usuario FTP
   - Contraseña: tu contraseña FTP
   - Puerto: 21
4. Haz clic en "Conexión rápida"

#### Paso 3: Subir archivos
1. En el panel izquierdo, navega a la carpeta de tu proyecto en tu computadora
2. En el panel derecho, navega a `/public_html`
3. Selecciona todos los archivos (index.html, styles.css, script.js, .htaccess)
4. Arrastra los archivos del lado izquierdo al derecho
5. Espera a que termine la transferencia

---

## 🔒 Configurar SSL (HTTPS) - IMPORTANTE

### Habilitar SSL gratuito en GoDaddy:

1. En tu panel de GoDaddy, ve a "Mis Productos"
2. Junto a tu hosting, haz clic en "Administrar"
3. Busca la sección "Certificado SSL"
4. Si dice "No protegido", haz clic en "Configurar"
5. GoDaddy ofrece SSL gratuito con Let's Encrypt
6. Selecciona tu dominio y haz clic en "Proteger"
7. Espera unos minutos a que se active (puede tomar hasta 24 horas)

### Una vez activado el SSL:

1. Edita el archivo `.htaccess` en cPanel
2. Descomenta (quita el #) de estas líneas:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>
```

3. Guarda el archivo
4. Ahora tu sitio redirigirá automáticamente a HTTPS

---

## ✏️ Personalizar tu sitio

### Contenido a modificar en `index.html`:

1. **Información de contacto** (líneas 157-177):
   - Dirección
   - Teléfono
   - Email

2. **Servicios** (líneas 55-90):
   - Títulos de servicios
   - Descripciones

3. **Sobre Nosotros** (líneas 96-124):
   - Historia de la empresa
   - Valores

4. **Redes Sociales** (líneas 236-240):
   - Agrega tus enlaces de Facebook, Instagram, etc.

### Colores en `styles.css` (líneas 2-9):

Cambia estos valores para personalizar los colores:
```css
--primary-color: #0066cc;    /* Color principal */
--secondary-color: #004999;  /* Color secundario */
--accent-color: #ff6b35;     /* Color de acento */
```

---

## 📧 Configurar el formulario de contacto

El formulario actualmente simula el envío. Para que funcione de verdad:

### Opción 1: Usar un servicio externo (Más fácil)
- **FormSpree** (https://formspree.io/)
- **EmailJS** (https://www.emailjs.com/)
- **Formsubmit** (https://formsubmit.co/)

### Opción 2: Crear un script PHP en tu servidor

1. Crea un archivo `contact.php` en `public_html`:

```php
<?php
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $nombre = htmlspecialchars($data['nombre']);
    $email = htmlspecialchars($data['email']);
    $telefono = htmlspecialchars($data['telefono']);
    $mensaje = htmlspecialchars($data['mensaje']);
    
    $to = "tu-email@gruporios-tampico.com"; // Cambia esto
    $subject = "Nuevo mensaje de contacto - Grupo Ríos Tampico";
    $body = "Nombre: $nombre\nEmail: $email\nTeléfono: $telefono\n\nMensaje:\n$mensaje";
    $headers = "From: $email";
    
    if (mail($to, $subject, $body, $headers)) {
        echo json_encode(['success' => true]);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false]);
    }
}
?>
```

2. Modifica `script.js` (línea 102) para usar tu script:

```javascript
const response = await fetch('/contact.php', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(formData)
});
```

---

## 🎨 Agregar imágenes

### Para agregar tu logo:

1. Sube tu logo a `public_html/images/logo.png`
2. En `index.html` (línea 18), cambia:

```html
<a href="#" class="logo">
    <img src="images/logo.png" alt="Grupo Ríos Tampico" style="height: 40px;">
</a>
```

### Para agregar una imagen en la sección "Nosotros":

1. Sube tu imagen a `public_html/images/about.jpg`
2. En `index.html` (líneas 118-126), reemplaza el `<div class="image-placeholder">` con:

```html
<div class="about-image">
    <img src="images/about.jpg" alt="Sobre Nosotros" style="width: 100%; border-radius: 20px;">
</div>
```

---

## ✅ Checklist final

- [ ] Todos los archivos están en `public_html`
- [ ] El archivo `.htaccess` está configurado
- [ ] SSL está activado (HTTPS)
- [ ] Has personalizado textos e información de contacto
- [ ] Has agregado tu logo (opcional)
- [ ] El formulario de contacto está configurado
- [ ] Has probado el sitio en diferentes navegadores
- [ ] Has probado la versión móvil (responsive)

---

## 🆘 Solución de problemas comunes

### Problema: La página no se ve, solo texto
**Solución:** Verifica que `styles.css` y `script.js` estén en la misma carpeta que `index.html`

### Problema: "403 Forbidden"
**Solución:** Verifica los permisos del archivo `index.html` (debe ser 644)

### Problema: No se ve el archivo `.htaccess`
**Solución:** En el Administrador de archivos, haz clic en "Configuración" y activa "Mostrar archivos ocultos"

### Problema: Los cambios no se ven
**Solución:** Limpia la caché del navegador (Ctrl + F5 en Windows, Cmd + Shift + R en Mac)

---

## 📞 Soporte

Si tienes problemas:
1. Contacta al soporte de GoDaddy: https://www.godaddy.com/help
2. Revisa la documentación de cPanel: https://docs.cpanel.net/

---

## 🎉 ¡Listo!

Tu página web profesional está lista para funcionar. Recuerda mantenerla actualizada y hacer backups regularmente desde cPanel.

**¡Éxito con Grupo Ríos Tampico!**
