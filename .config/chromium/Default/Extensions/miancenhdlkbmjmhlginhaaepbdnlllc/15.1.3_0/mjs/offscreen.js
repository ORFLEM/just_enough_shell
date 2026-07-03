/**
 * offscreen.js
 */

/* shared */
import '../lib/mozilla/browser-polyfill.min.js';
import { handleMsg } from './offscreen-main.js';

/* api */
const { runtime } = browser;

/* listener */
runtime.onMessage.addListener(handleMsg);
