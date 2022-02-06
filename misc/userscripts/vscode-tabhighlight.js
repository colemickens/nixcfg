// ==UserScript==
// @name        New script - cleo.cat
// @namespace   Violentmonkey Scripts
// @match       https://code.x.cleo.cat/
// @grant       none
// @version     1.0
// @author      -
// @description 2/5/2022, 7:16:18 PM
// ==/UserScript==

function addGlobalStyle(css) {
    var head, style;
    head = document.getElementsByTagName('head')[0];
    if (!head) { return; }
    style = document.createElement('style');
    style.type = 'text/css';
    style.innerHTML = css;
    head.appendChild(style);
}

let assignments = {
  "~/code/nixcfg":          "darkviolet",
  "~/code/nixpkgs":         "dodgerblue",
  "~/code/nixpkgs/cmpkgs":  "deeppink",
  "~/code/tow-boot":        "orange",
  "~/code/mobile-nixos":    "green",
};


let customCSS = `
  .tab {
    border-top-style: double !important;
    border-top-width: 3px !important;
    border-bottom-style: double !important;
    border-bottom-width: 3px !important;
  }

  .tab.active {
    border-bottom-style: outset !important;
    border-top-style: outset !important;
    font-weight: bold;
  }
`;

for (const [key, value] of Object.entries(assignments)) {
  console.log(key, value);
  customCSS = customCSS.concat(`
    .tab[title*="${key}"] {
      border-top-color: ${value} !important;
      border-bottom-color: ${value} !important;
    }

  `);
}

addGlobalStyle(customCSS);
