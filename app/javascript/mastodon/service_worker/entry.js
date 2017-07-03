// This is used as the "entry" for the service worker, i.e.
// additional code that is not generated by the offline-plugin.
// In general, this code is used for resources that should be cached
// on-the-fly or that aren't part of the Webpack asset graph, because
// offline-plugin isn't very well-adapted to that use case.

import {
  precache,
  cacheFirst,
  cacheFirstAndUpdateAfter,
  networkFirst,
  deleteAllFromCacheMatching,
  onRequest
} from './helpers';

const SIGN_OUT_REGEX = /^\/auth\/sign_out/;
const EMOJI_REGEX = /^\/emoji\//;
const WEB_REGEX = /^\/web\//;
const ABOUT_REGEX = /^\/about/;
const SETTINGS_REGEX = /^\/settings\//
const USER_SENSITIVE_DATA = ['/web', '/settings'];

// precache these URLs so they're always guaranteed to work. one is the
// default homepage for desktop, the other is the one for manifest.json
precache([
  '/web/getting-started',
  '/web/timelines/home'
]);

// these resources can just be cached-on-the-fly. There's no need to update,
// because the emoji versions are embedded as URL params
cacheFirst('GET', EMOJI_REGEX);

// these resources should be updated whenever possible, because they contain
// CSRF tokens embedded in the HTML and may also be updated (e.g. when a
// user becomes an admin, their "Preferences" page is updated to include
// the "Administration" section
cacheFirstAndUpdateAfter('GET', WEB_REGEX);
cacheFirstAndUpdateAfter('GET', ABOUT_REGEX);

// this seems more useful as network-first, since stuff here can frequently
// change (e.g. the admin console) and it's annoying to have to always refresh
networkFirst('GET', SETTINGS_REGEX);

// on sign out, clear any /web paths because we need to update the
// csrf-token (whereas everything else is static, no harm in caching)
onRequest('POST', SIGN_OUT_REGEX, () => {
  deleteAllFromCacheMatching(USER_SENSITIVE_DATA);
});
