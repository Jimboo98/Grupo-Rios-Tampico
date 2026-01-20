# Plan de Implementación – Grupo Ríos Tampico

## Arquitectura & Navegación
- [x] Menú principal: Inicio, Quiénes Somos, Divisiones (Suministros de Construcción e industriales, Ríos Logistics Advisory, Desarrollo Inmobiliario), Proyectos (futuro), Contacto
- [x] Footer: Aviso de privacidad, Términos y condiciones, “Operado por Arrendamientos y Construcciones de Tampico”, contactos rápidos por división
- [ ] URLs limpias: /, /quienes-somos, /suministros-industriales, /logistics-advisory, /desarrollo-inmobiliario, /contacto

## Wireframes (estructura por página)
- [x] Home: Header pegajoso, Hero (H1/H2 + 4 CTAs), bloque Quiénes Somos resumido, cards de 3 divisiones, slogan, CTA contacto, footer legal
- [x] Quiénes Somos: intro corporativa, misión, visión, valores, enfoque, CTA a divisiones
- [x] Plantilla de División (reusable): Hero, sub-misión, descripción, servicios/categorías, enfoque/metodología, CTA contacto específico
- [x] Contacto: selector de división, formulario corto, datos corporativos y teléfonos/correos, footer legal
- [ ] Proyectos (futuro): cards/galería con filtros

## Contenido & SEO
- [x] Insertar H1/H2 y copys SEO provistos en cada sección
- [x] Mantener nombre fiscal solo en footer/avisos (“Operado por…”) y no en héroes ni menús
- [ ] Metas: title + description por página; Open Graph/Twitter cards
- [ ] Alt en imágenes y estructura semántica (header/nav/main/section/article/footer)
- [ ] Sitemap.xml y robots.txt con canonical por página

## Branding & UI
- [x] Usar paleta existente (no cambiar colores)
- [x] Tipos: títulos Montserrat/Poppins/Inter; cuerpo Open Sans/Lato/Roboto; sans-serif legible
- [x] Estilo: corporativo limpio, bloques claros, íconos lineales, foto real (industria, logística, arquitectura)
- [x] Personalidad por división: Suministros (industrial/robusto), Logistics (analítico/ejecutivo), Inmobiliario (moderno/aspiracional)

## Componentes clave
- [x] Header con dropdown de Divisiones y CTA destacado
- [x] Hero con CTA primario/secundario
- [x] Cards de divisiones con breve descriptor + CTA
- [x] Sección valores (chips/badges) y misión/visión en dos columnas
- [x] Listas de servicios/categorías claras; pasos de metodología
- [ ] Formulario de contacto con selector de división y campos mínimos (nombre, email, teléfono, mensaje)

## Performance & Accesibilidad
- [ ] Imágenes optimizadas (WebP/JPEG) con lazy-load
- [ ] Contraste AA, focus visible, labels en formularios, aria-label en íconos
- [ ] Mobile-first con breakpoints probados (≥320px)

## Roadmap
- [x] Maquetar wireframes base en HTML/CSS responsivo reutilizando estilos actuales
- [x] Integrar copys SEO por página/sección
- [x] Crear componentes (hero, cards, listas, formularios, footer legal)
- [x] Añadir datos de contacto y CTAs por división
- [ ] Optimizar imágenes y accesibilidad
- [ ] Configurar metas, sitemap y robots
- [ ] QA responsive y performance (Lighthouse)
- [ ] Despliegue y verificación final
