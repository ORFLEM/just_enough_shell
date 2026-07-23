/* Matugen Template for userContent.css */

@media (prefers-color-scheme: dark) {

  /* Common variables affecting all pages */
  @-moz-document url-prefix("about:") {
    :root {
      --in-content-page-color: {{colors.on_surface.default.hex}} !important;
      --color-accent-primary: {{colors.primary.default.hex}} !important;
      --color-accent-primary-hover: {{colors.primary_container.default.hex}} !important;
      --color-accent-primary-active: {{colors.on_primary_container.default.hex}} !important;
      background-color: {{colors.surface.default.hex}} !important;
      --in-content-page-background: {{colors.surface.default.hex}} !important;
    }

  }

  /* Variables and styles specific to about:newtab and about:home */
  @-moz-document url("about:newtab"), url("about:home") {

    :root {
      --newtab-background-color: {{colors.surface.default.hex}} !important;
      --newtab-background-color-secondary: {{colors.surface_variant.default.hex}} !important;
      --newtab-element-hover-color: {{colors.surface_variant.default.hex}} !important;
      --newtab-text-primary-color: {{colors.on_surface.default.hex}} !important;
      --newtab-wordmark-color: {{colors.on_surface.default.hex}} !important;
      --newtab-primary-action-background: {{colors.primary.default.hex}} !important;
    }

    .icon {
      color: {{colors.primary.default.hex}} !important;
    }

    .search-wrapper .logo-and-wordmark .logo {
      background: url("zen-logo-mocha.svg"), url("https://raw.githubusercontent.com/IAmJafeth/zen-browser/main/themes/Mocha/Green/zen-logo-mocha.svg") no-repeat center !important;
      display: inline-block !important;
      height: 82px !important;
      width: 82px !important;
      background-size: 82px !important;
    }

    @media (max-width: 609px) {
      .search-wrapper .logo-and-wordmark .logo {
        background-size: 64px !important;
        height: 64px !important;
        width: 64px !important;
      }
    }

    .card-outer:is(:hover, :focus, .active):not(.placeholder) .card-title {
      color: {{colors.primary.default.hex}} !important;
    }

    .top-site-outer .search-topsite {
      background-color: {{colors.tertiary.default.hex}} !important;
    }

    .compact-cards .card-outer .card-context .card-context-icon.icon-download {
      fill: {{colors.primary.default.hex}} !important;
    }
  }

  /* Variables and styles specific to about:preferences */
  @-moz-document url-prefix("about:preferences") {
    :root {
      --zen-colors-tertiary: {{colors.background.default.hex}} !important;
      --in-content-text-color: {{colors.on_surface.default.hex}} !important;
      --link-color: {{colors.primary.default.hex}} !important;
      --link-color-hover: {{colors.primary_container.default.hex}} !important;
      --zen-colors-primary: {{colors.surface_variant.default.hex}} !important;
      --in-content-box-background: {{colors.surface_variant.default.hex}} !important;
      --zen-primary-color: {{colors.primary.default.hex}} !important;
    }

    groupbox , moz-card{
      background: {{colors.surface.default.hex}} !important;
    }

    button,
    groupbox menulist {
      background: {{colors.surface_variant.default.hex}} !important;
      color: {{colors.on_surface.default.hex}} !important;
    }

    .main-content {
      background-color: {{colors.background.default.hex}} !important;
    }

    .identity-color-blue {
      --identity-tab-color: {{colors.tertiary.default.hex}} !important;
      --identity-icon-color: {{colors.tertiary.default.hex}} !important;
    }

    .identity-color-turquoise {
      --identity-tab-color: {{colors.tertiary_container.default.hex}} !important;
      --identity-icon-color: {{colors.tertiary_container.default.hex}} !important;
    }

    .identity-color-green {
      --identity-tab-color: {{colors.primary.default.hex}} !important;
      --identity-icon-color: {{colors.primary.default.hex}} !important;
    }

    .identity-color-yellow {
      --identity-tab-color: {{colors.secondary.default.hex}} !important;
      --identity-icon-color: {{colors.secondary.default.hex}} !important;
    }

    .identity-color-orange {
      --identity-tab-color: {{colors.error.default.hex}} !important;
      --identity-icon-color: {{colors.error.default.hex}} !important;
    }

    .identity-color-red {
      --identity-tab-color: {{colors.error_container.default.hex}} !important;
      --identity-icon-color: {{colors.error_container.default.hex}} !important;
    }

    .identity-color-pink {
      --identity-tab-color: {{colors.primary_container.default.hex}} !important;
      --identity-icon-color: {{colors.primary_container.default.hex}} !important;
    }

    .identity-color-purple {
      --identity-tab-color: {{colors.secondary_container.default.hex}} !important;
      --identity-icon-color: {{colors.secondary_container.default.hex}} !important;
    }
  }

  /* Variables and styles specific to about:addons */
  @-moz-document url-prefix("about:addons") {
    :root {
      --zen-dark-color-mix-base: {{colors.background.default.hex}} !important;
      --background-color-box: {{colors.surface.default.hex}} !important;
    }
  }

  /* Variables and styles specific to about:protections */
  @-moz-document url-prefix("about:protections") {
    :root {
      --zen-primary-color: {{colors.surface.default.hex}} !important;
      --social-color: {{colors.secondary_container.default.hex}} !important;
      --coockie-color: {{colors.tertiary_container.default.hex}} !important;
      --fingerprinter-color: {{colors.secondary.default.hex}} !important;
      --cryptominer-color: {{colors.tertiary.default.hex}} !important;
      --tracker-color: {{colors.primary.default.hex}} !important;
      --in-content-primary-button-background-hover: {{colors.surface_variant.default.hex}} !important;
      --in-content-primary-button-text-color-hover: {{colors.on_surface.default.hex}} !important;
      --in-content-primary-button-background: {{colors.surface_variant.default.hex}} !important;
      --in-content-primary-button-text-color: {{colors.on_surface.default.hex}} !important;
    }


    .card {
      background-color: {{colors.surface_variant.default.hex}} !important;
    }
  }
}
