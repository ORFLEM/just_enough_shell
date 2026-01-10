/* Matugen Template for userChrome.css */

@media (prefers-color-scheme: dark) {
  :root {
    --zen-colors-primary: {{colors.surface_variant.default.hex}} !important;
    --zen-primary-color: {{colors.primary.default.hex}} !important;
    --zen-colors-secondary: {{colors.surface_variant.default.hex}} !important;
    --zen-colors-tertiary: {{colors.background.default.hex}} !important;
    --zen-colors-border: {{colors.primary.default.hex}} !important;
    --toolbarbutton-icon-fill: {{colors.primary.default.hex}} !important;
    --lwt-text-color: {{colors.on_surface.default.hex}} !important;
    --toolbar-field-color: {{colors.on_surface.default.hex}} !important;
    --tab-selected-textcolor: {{colors.on_primary_container.default.hex}} !important;
    --toolbar-field-focus-color: {{colors.on_surface.default.hex}} !important;
    --toolbar-color: {{colors.on_surface.default.hex}} !important;
    --newtab-text-primary-color: {{colors.on_surface.default.hex}} !important;
    --arrowpanel-color: {{colors.on_surface.default.hex}} !important;
    --arrowpanel-background: {{colors.surface.default.hex}} !important;
    --sidebar-text-color: {{colors.on_surface.default.hex}} !important;
    --lwt-sidebar-text-color: {{colors.on_surface.default.hex}} !important;
    --lwt-sidebar-background-color: {{colors.background.default.hex}} !important;
    --toolbar-bgcolor: {{colors.surface_variant.default.hex}} !important;
    --newtab-background-color: {{colors.surface.default.hex}} !important;
    --zen-themed-toolbar-bg: {{colors.background.default.hex}} !important;
    --zen-main-browser-background: {{colors.background.default.hex}} !important;
    --toolbox-bgcolor-inactive: {{colors.background.default.hex}} !important;
  }

  #permissions-granted-icon {
    color: {{colors.background.default.hex}} !important;
  }

  .sidebar-placesTree {
    background-color: {{colors.surface.default.hex}} !important;
  }

  #zen-workspaces-button {
    background-color: {{colors.surface.default.hex}} !important;
  }

  #TabsToolbar {
    background-color: {{colors.background.default.hex}} !important;
  }

  #urlbar-background {
    background-color: {{colors.surface.default.hex}} !important;
  }

  .content-shortcuts {
    background-color: {{colors.surface.default.hex}} !important;
    border-color: {{colors.primary.default.hex}} !important;
  }

  .urlbarView-url {
    color: {{colors.primary.default.hex}} !important;
  }

  #zenEditBookmarkPanelFaviconContainer {
    background: {{colors.background.default.hex}} !important;
  }

  #zen-media-controls-toolbar {
    & #zen-media-progress-bar {
      &::-moz-range-track {
        background: {{colors.surface_variant.default.hex}} !important;
      }
    }
  }

  toolbar .toolbarbutton-1 {
    &:not([disabled]) {
      &:is([open], [checked])
        > :is(
          .toolbarbutton-icon,
          .toolbarbutton-text,
          .toolbarbutton-badge-stack
        ) {
        fill: {{colors.background.default.hex}};
      }
    }
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

  hbox#titlebar {
    background-color: {{colors.background.default.hex}} !important;
  }

  #zen-appcontent-navbar-container {
    background-color: {{colors.background.default.hex}} !important;
  }
}
