<script lang="ts">
  import { onMount } from 'svelte';
  import { asset, resolve } from '$app/paths';
  import { COPY, LANGUAGES, SITE_URL, REPOSITORY_URL, DOWNLOAD_URL, type Locale } from './content.js';
  import Mascot from './Mascot.svelte';

  let { locale }: { locale: Locale } = $props();
  const copy = $derived(COPY[locale]);
  const language = $derived(LANGUAGES.find(item => item.code === locale) ?? LANGUAGES[0]);
  const canonical = $derived(`${SITE_URL}${language.path}`);
  let theme = $state('system');
  let ready = $state(false);
  let playing = $state(false);
  let downloadCount = $state(0);
  const localeHref = (code: string) => code === 'zh' ? resolve('/zh') : code === 'ja' ? resolve('/ja') : resolve('/');
  const openGraphLocale = (code: string) => code === 'zh' ? 'zh_CN' : code === 'ja' ? 'ja_JP' : 'en_US';
  const ogLocale = $derived(openGraphLocale(locale));

  const schema = $derived(JSON.stringify({
    '@context': 'https://schema.org', '@type': 'SoftwareApplication',
    '@id': `${canonical}#software`, name: 'MouseSpell',
    operatingSystem: 'macOS 15 or later', applicationCategory: 'UtilitiesApplication',
    applicationSubCategory: 'macOS mouse shortcut utility',
    softwareVersion: '1.0.1', description: copy.description, url: canonical,
    mainEntityOfPage: { '@type': 'WebPage', '@id': canonical },
    image: `${SITE_URL}/media/icon.png`, screenshot: `${SITE_URL}/media/settings.png`,
    downloadUrl: DOWNLOAD_URL, installUrl: `${REPOSITORY_URL}/releases/tag/v1.0.1`,
    identifier: { '@type': 'PropertyValue', propertyID: 'CFBundleIdentifier', value: 'io.github.clutch.Clutch' },
    keywords: copy.keywords.join(', '), featureList: copy.actions.map(action => action[1]),
    license: `${REPOSITORY_URL}/blob/main/LICENSE`, inLanguage: language.html,
    isAccessibleForFree: true,
    author: { '@type': 'Organization', name: 'TreatTrick', url: REPOSITORY_URL },
    publisher: { '@type': 'Organization', name: 'TreatTrick', url: REPOSITORY_URL },
    brand: { '@type': 'Brand', name: 'MouseSpell', logo: `${SITE_URL}/media/icon.png` },
    sameAs: [REPOSITORY_URL],
    offers: {
      '@type': 'Offer', price: '0', priceCurrency: 'USD',
      availability: 'https://schema.org/InStock', url: DOWNLOAD_URL
    }
  }).replaceAll('<', '\\u003c'));

  onMount(() => {
    theme = document.documentElement.dataset.theme ?? 'system';
    ready = true;
    const motion = window.matchMedia('(prefers-reduced-motion: reduce)');
    playing = !motion.matches;
    const respectMotion = () => { if (motion.matches) playing = false; };
    motion.addEventListener('change', respectMotion);
    return () => motion.removeEventListener('change', respectMotion);
  });

  const changeTheme = () => {
    document.documentElement.dataset.theme = theme;
    try {
      localStorage.setItem('clutch-theme', theme);
    } catch {
      // 浏览器禁用持久存储时，当前页面仍然可以正常切换外观。
      console.info('Appearance preference will only apply to this page.');
    }
  };
</script>

<svelte:head>
  <title>{copy.title}</title>
  <meta name="description" content={copy.description} />
  <meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1" />
  <meta name="googlebot" content="index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1" />
  <meta name="application-name" content="MouseSpell" />
  <meta name="apple-mobile-web-app-title" content="MouseSpell" />
  <meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)" />
  <meta name="theme-color" content="#13151b" media="(prefers-color-scheme: dark)" />
  <link rel="canonical" href={canonical} />
  <link rel="icon" href={asset('media/icon.png')} type="image/png" />
  <link rel="sitemap" type="application/xml" href={`${SITE_URL}/sitemap.xml`} />
  {#each LANGUAGES as alternate}
    <link rel="alternate" hreflang={alternate.html} href={`${SITE_URL}${alternate.path}`} />
  {/each}
  <link rel="alternate" hreflang="x-default" href={`${SITE_URL}/`} />
  <meta property="og:type" content="website" />
  <meta property="og:site_name" content="MouseSpell" />
  <meta property="og:locale" content={ogLocale} />
  {#each LANGUAGES.filter(alternate => alternate.code !== locale) as alternate}
    <meta property="og:locale:alternate" content={openGraphLocale(alternate.code)} />
  {/each}
  <meta property="og:title" content={copy.title} />
  <meta property="og:description" content={copy.description} />
  <meta property="og:url" content={canonical} />
  <meta property="og:image" content={`${SITE_URL}/media/settings.png`} />
  <meta property="og:image:alt" content={copy.screenshotAlt} />
  <meta property="og:image:type" content="image/png" />
  <meta property="og:image:width" content="1164" />
  <meta property="og:image:height" content="900" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content={copy.title} />
  <meta name="twitter:description" content={copy.description} />
  <meta name="twitter:image" content={`${SITE_URL}/media/settings.png`} />
  <meta name="twitter:image:alt" content={copy.screenshotAlt} />
  {@html `<script type="application/ld+json">${schema}</script>`}
</svelte:head>

{#snippet downloadIcon()}
  <svg viewBox="0 0 24 24" width="19" height="19" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v12m-4-4 4 4 4-4M5 16v4h14v-4" /></svg>
{/snippet}

<a class="skip-link" href="#main">{copy.skip}</a>
<header class="site-header wrap">
  <a class="brand" href={localeHref(locale)} aria-label="MouseSpell">
    <img src={asset('media/icon.png')} width="32" height="32" alt="" />
    <span>MouseSpell</span>
  </a>
  <nav class="section-nav" aria-label={copy.features}>
    <a href="#features">{copy.features}</a>
    <a href="#setup">{copy.setup}</a>
    <a href={REPOSITORY_URL}>GitHub <span aria-hidden="true">↗</span></a>
  </nav>
  <div class="preferences">
    <label class="appearance-control" hidden={!ready}>
      <span class="sr-only">{copy.appearance}</span>
      <span aria-hidden="true">◐</span>
      <select aria-label={copy.appearance} bind:value={theme} onchange={changeTheme}>
        <option value="system">{copy.system}</option>
        <option value="light">{copy.light}</option>
        <option value="dark">{copy.dark}</option>
      </select>
    </label>
    <details class="language-menu">
      <summary aria-label={`${copy.language}: ${language.label}`}>{language.label}<span aria-hidden="true">⌄</span></summary>
      <nav aria-label={copy.language} data-sveltekit-reload>
        {#each LANGUAGES as item}
          <a href={localeHref(item.code)} lang={item.html} hreflang={item.html} aria-current={item.code === locale ? 'page' : undefined}>{item.label}<span aria-hidden="true">{item.code === locale ? '✓' : ''}</span></a>
        {/each}
      </nav>
    </details>
  </div>
</header>

<main id="main">
  <section class="hero wrap" aria-labelledby="hero-heading">
    <p class="hero-badge"><span class="status-dot" aria-hidden="true"></span>{copy.badge}</p>
    <h1 id="hero-heading">{copy.headline[0]}<br /><span>{copy.headline[1]}</span></h1>
    <p class="hero-intro">{copy.intro}</p>
    <div class="hero-actions">
      <a class="button primary" href={DOWNLOAD_URL} onclick={() => { downloadCount += 1; }}>{@render downloadIcon()}{copy.download}</a>
      <a class="text-link" href={REPOSITORY_URL}>{copy.source}<span aria-hidden="true">↗</span></a>
    </div>
    <p class="release-meta">{copy.requirements}<span aria-hidden="true">·</span>{copy.free}</p>
    <figure class="demo">
      <div class="demo-toolbar"><span>{copy.demoBinding}</span><button type="button" hidden={!ready} aria-pressed={playing} onclick={() => playing = !playing}><span aria-hidden="true">{playing ? 'Ⅱ' : '▷'}</span>{playing ? copy.pause : copy.play}</button></div>
      <img class="demo-image" src={playing ? asset('media/desktop-switching-demo.gif') : asset('demo-poster.webp')} alt={copy.demoAlt} width="900" height="624" fetchpriority="high" />
      <figcaption>{copy.demoCaption}</figcaption>
    </figure>
  </section>

  <section class="features wrap section" id="features" aria-labelledby="features-heading">
    <div class="section-heading"><h2 id="features-heading">{copy.actionsHeading}</h2><p>{copy.actionsIntro}</p></div>
    <ul class="action-list">
      {#each copy.actions as action}
        <li><span class="action-symbol" aria-hidden="true">{action[0]}</span><div><h3>{action[1]}</h3><p>{action[2]}</p></div></li>
      {/each}
    </ul>
    <p class="trigger-note">{copy.triggerNote}</p>
  </section>

  <section class="setup-section" id="setup" aria-labelledby="setup-heading">
    <div class="wrap setup-layout">
      <div><h2 id="setup-heading">{copy.setupHeading}</h2><p class="section-intro">{copy.setupIntro}</p>
        <ol class="setup-steps">
          {#each copy.steps as step, index}
            <li><span class="step-number" aria-hidden="true">{index + 1}</span><div><h3>{step[0]}</h3><p>{step[1]}</p></div></li>
          {/each}
        </ol>
      </div>
      <div class="settings-preview">
        <img class="shot-light" src={asset('media/settings.png')} alt={copy.screenshotAlt} width="1164" height="900" loading="lazy" />
        <img class="shot-dark" src={asset('media/settings-dark.png')} alt={copy.screenshotAlt} width="1164" height="900" loading="lazy" />
      </div>
    </div>
  </section>

  <section class="privacy wrap section" aria-labelledby="privacy-heading">
    <div><h2 id="privacy-heading">{copy.privacyHeading}</h2><p>{copy.privacyText}</p></div>
    <ul>{#each copy.privacyFacts as fact}<li><span aria-hidden="true">✓</span>{fact}</li>{/each}</ul>
  </section>

  <section class="install wrap section" id="install" aria-labelledby="install-heading">
    <div class="install-top"><div><img src={asset('media/icon.png')} alt="" width="56" height="56" loading="lazy" /><h2 id="install-heading">{copy.installHeading}</h2><p>{copy.installIntro}</p></div><div class="install-cta"><a class="button primary" href={DOWNLOAD_URL} onclick={() => { downloadCount += 1; }}>{@render downloadIcon()}{copy.download}</a><p class="release-meta">{copy.requirements}</p></div></div>
    <p class="install-note">{copy.installNote}</p>
    <details class="installation-details">
      <summary>{copy.installDetails}<span aria-hidden="true">+</span></summary>
      <ol>{#each copy.installSteps as step}<li><h3>{step[0]}</h3><p>{step[1]}</p></li>{/each}</ol>
    </details>
  </section>
</main>

<footer class="site-footer wrap"><div><a class="brand" href={localeHref(locale)}>MouseSpell</a><p>{copy.footer}</p></div><nav aria-label="MouseSpell"><a href={REPOSITORY_URL}>GitHub ↗</a><a href={`${REPOSITORY_URL}/releases`}>{copy.releases}</a><a href={`${REPOSITORY_URL}/blob/main/LICENSE`}>MIT</a></nav></footer>

<Mascot {locale} celebration={downloadCount} />
