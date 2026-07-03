/**
 * options.js
 */

/* shared */
import '../lib/mozilla/browser-polyfill.min.js';
import { throwErr } from './common.js';
import { showToolbarIconOptions } from './compat.js';
import { localizeHtml } from './localize.js';
import {
  addButtonClickListener, addInputChangeListener, setValuesFromStorage
} from './options-main.js';

/* startup */
Promise.all([
  localizeHtml(),
  setValuesFromStorage(),
  addButtonClickListener(),
  addInputChangeListener(),
  showToolbarIconOptions()
]).catch(throwErr);
