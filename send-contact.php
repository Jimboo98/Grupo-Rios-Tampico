<?php
// SMTP contact form handler using PHPMailer.
// Configure SMTP credentials and upload PHPMailer (https://github.com/PHPMailer/PHPMailer)
// Place the PHPMailer src folder under lib/PHPMailer/ or adjust paths below.

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Adjust path to your PHPMailer installation
require __DIR__ . '/lib/PHPMailer/src/Exception.php';
require __DIR__ . '/lib/PHPMailer/src/PHPMailer.php';
require __DIR__ . '/lib/PHPMailer/src/SMTP.php';

header('Content-Type: application/json');

function respond($success, $message) {
    echo json_encode(['success' => $success, 'message' => $message]);
    exit;
}

// Simple honeypot
if (!empty($_POST['website'])) {
    respond(false, 'Spam detectado');
}

$nombre   = trim($_POST['nombre'] ?? '');
$empresa  = trim($_POST['empresa'] ?? '');
$correo   = trim($_POST['correo'] ?? '');
$telefono = trim($_POST['telefono'] ?? '');
$division = trim($_POST['division'] ?? '');
$mensaje  = trim($_POST['mensaje'] ?? '');

if ($nombre === '' || $correo === '' || $division === '' || $mensaje === '') {
    respond(false, 'Faltan campos obligatorios');
}

if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
    respond(false, 'Correo inválido');
}

// Map division to recipient
$recipients = [
    'suministros'  => 'franciscorios@gruporiostampico.com',
    'logistica'    => 'miguelrios@gruporiostampico.com',
    'inmobiliario' => 'nallelybello@gruporiostampico.com',
    'general'      => 'miguelrios@gruporiostampico.com',
];

$toEmail = $recipients[$division] ?? $recipients['general'];

// Intentar primero con mail() de PHP (recomendado por GoDaddy)
try {
    $mail = new PHPMailer(true);
    
    // Usar mail() nativo de PHP
    $mail->isMail();
    
    // Usar cuenta real de Office 365 como remitente para pasar validaciones SPF/DKIM
    // El Reply-To apunta al visitante para que puedas responder directamente
    $mail->setFrom('miguelrios@gruporiostampico.com', 'Formulario Web - Grupo Ríos');
    $mail->addAddress($toEmail);
    $mail->addReplyTo($correo, $nombre);
    
    $mail->CharSet = 'UTF-8';
    $mail->isHTML(true);
    $mail->Subject = 'Contacto desde web - ' . $nombre;
    
    // Cuerpo HTML con diseño
    $htmlBody = '
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { font-family: Inter, Arial, sans-serif; background-color: #f7f3ec; margin: 0; padding: 0; }
            .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }
            .header { background: linear-gradient(135deg, #2b3f4e 0%, #1f2f3d 100%); padding: 40px 30px; text-align: center; }
            .header h1 { color: #ffffff; margin: 0; font-size: 28px; font-weight: 700; }
            .header p { color: #c47a3d; margin: 10px 0 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px; }
            .content { padding: 40px 30px; }
            .field { margin-bottom: 24px; }
            .field-label { color: #2b3f4e; font-weight: 600; font-size: 14px; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; }
            .field-value { color: #374151; font-size: 16px; line-height: 1.6; }
            .message-box { background-color: #f7f3ec; border-left: 4px solid #c47a3d; padding: 20px; margin-top: 10px; border-radius: 4px; }
            .footer { background-color: #2b3f4e; color: #9ca3af; padding: 30px; text-align: center; font-size: 13px; }
            .footer a { color: #c47a3d; text-decoration: none; }
            .divider { height: 1px; background-color: #e5e7eb; margin: 30px 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Grupo Ríos Tampico</h1>
                <p>Nuevo mensaje de contacto</p>
            </div>
            <div class="content">
                <div class="field">
                    <div class="field-label">Nombre completo</div>
                    <div class="field-value">' . htmlspecialchars($nombre, ENT_QUOTES, 'UTF-8') . '</div>
                </div>
                
                <div class="field">
                    <div class="field-label">Empresa</div>
                    <div class="field-value">' . htmlspecialchars($empresa !== '' ? $empresa : 'No especificada', ENT_QUOTES, 'UTF-8') . '</div>
                </div>
                
                <div class="field">
                    <div class="field-label">Correo electrónico</div>
                    <div class="field-value"><a href="mailto:' . htmlspecialchars($correo, ENT_QUOTES, 'UTF-8') . '" style="color: #c47a3d; text-decoration: none;">' . htmlspecialchars($correo, ENT_QUOTES, 'UTF-8') . '</a></div>
                </div>
                
                <div class="field">
                    <div class="field-label">Teléfono</div>
                    <div class="field-value">' . htmlspecialchars($telefono !== '' ? $telefono : 'No especificado', ENT_QUOTES, 'UTF-8') . '</div>
                </div>
                
                <div class="field">
                    <div class="field-label">División de interés</div>
                    <div class="field-value">' . htmlspecialchars(ucfirst($division), ENT_QUOTES, 'UTF-8') . '</div>
                </div>
                
                <div class="divider"></div>
                
                <div class="field">
                    <div class="field-label">Mensaje</div>
                    <div class="message-box">' . nl2br(htmlspecialchars($mensaje, ENT_QUOTES, 'UTF-8')) . '</div>
                </div>
            </div>
            <div class="footer">
                <p>Este mensaje fue enviado desde el formulario de contacto de <a href="https://gruporiostampico.com">gruporiostampico.com</a></p>
                <p style="margin-top: 10px; color: #6b7280;">Este correo es informativo. No responder a esta dirección.</p>
            </div>
        </div>
    </body>
    </html>';
    
    // Versión texto plano como alternativa
    $textBody = "Nuevo mensaje de contacto - Grupo Ríos Tampico\n\n";
    $textBody .= "NOMBRE: " . $nombre . "\n";
    $textBody .= "EMPRESA: " . ($empresa !== '' ? $empresa : 'No especificada') . "\n";
    $textBody .= "CORREO: " . $correo . "\n";
    $textBody .= "TELÉFONO: " . ($telefono !== '' ? $telefono : 'No especificado') . "\n";
    $textBody .= "DIVISIÓN: " . $division . "\n\n";
    $textBody .= "MENSAJE:\n" . $mensaje . "\n\n";
    $textBody .= "---\nEste mensaje fue enviado desde gruporiostampico.com";
    
    $mail->Body = $htmlBody;
    $mail->AltBody = $textBody;
    
    $mail->send();
    respond(true, 'Mensaje enviado exitosamente');
    
} catch (Exception $e) {
    respond(false, 'Error al enviar: ' . $mail->ErrorInfo);
}

