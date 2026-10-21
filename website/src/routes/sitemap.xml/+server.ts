import { LANGUAGES, SITE_URL } from '#lib/content.js';

export const prerender = true;

export const GET = () => new Response(
  `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">${LANGUAGES.map(language => `<url><loc>${SITE_URL}${language.path}</loc>${LANGUAGES.map(alternate => `<xhtml:link rel="alternate" hreflang="${alternate.html}" href="${SITE_URL}${alternate.path}"/>`).join('')}</url>`).join('')}</urlset>`,
  { headers: { 'Content-Type': 'application/xml; charset=utf-8' } }
);
