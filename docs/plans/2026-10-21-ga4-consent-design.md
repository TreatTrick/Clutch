# Website GA4 Consent and Event Design

## Goal

Measure page visits and Clutch download-button clicks across the English, Simplified Chinese, and Japanese website pages, so the owner can compare search traffic with downloads.

## Approved behavior

The visitor's analytics choice is opt-in. The Google Analytics script is not requested until the visitor chooses to allow analytics. The first visit shows localized allow and reject controls. The footer provides a persistent way to reopen the choice. The stored choice applies across the three locale pages; if browser storage is unavailable, the decision applies only until that page closes.

When analytics is allowed, send one `page_view` per page load and a `download_click` event from either Clutch download button. Include only the page locale and button placement with the download event. Do not send analytics events before consent. After rejecting or withdrawing consent, stop future events and update GA4 consent state if its script was already loaded. Previously collected data remains in GA4.

The GA4 account's optional data-sharing switches stay off. The website does not use advertising features or send personal information. Clutch itself continues to process shortcuts locally; website analytics is separate and opt-in.

## Architecture

Add a small analytics helper that reads and stores the consent choice, injects the Google tag only when consent is granted, disables the tag's automatic page view, and exposes page-view and download-click events. Keep the measurement ID in one configuration constant. `Landing.svelte` owns the localized visitor controls and calls the helper from its existing mount and download-link flows. `content.ts` owns all English, Chinese, and Japanese copy, and `app.css` styles the notice without blocking the mascot or page controls.

The footer settings link reopens the same controls. Accepting loads or enables GA4 and records the current page view; changing locale then records that locale's page view. Rejecting stores the choice without loading the script. No consent-mode pings are sent before opt-in.

## Validation

Automated tests verify that an unset or denied choice does not inject the tag, a granted choice injects it once, consent persists, and events contain only the intended fields. `pnpm check` and `pnpm build` validate the static site. The live site is checked for all three locales, the visible choice, no analytics request before consent, and page/download events after consent.
