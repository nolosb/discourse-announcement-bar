import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';
import { defaultHomepage } from 'discourse/lib/utilities';
import icon from 'discourse-common/helpers/d-icon';
import i18n from 'discourse-common/helpers/i18n';
import I18n from 'discourse-i18n';
import and from 'truth-helpers/helpers/and';

export default class AnnouncementBar extends Component {
  @service site;
  @service siteSettings;
  @service router;
  @service keyValueStore;
  @tracked dismissed = false;

  get storageKey() {
    return `announcement-bar-dismissed-${I18n.t(themePrefix("announcement_bar.text"))}`;
  }

  get isVisible() {
    if (this.dismissed) {
      return false;
    }
    return !this.keyValueStore.get(this.storageKey);
  }

  <template>
    {{#if (and this.showOnRoute this.showOnMobile this.isVisible)}}
      <div class='announcement-bar__wrapper {{settings.plugin_outlet}}'>
        <div class='announcement-bar__container'>
          <div class='announcement-bar__content'>
            <span>{{i18n (themePrefix "announcement_bar.text")}}</span>
            <a
              class='btn btn-primary'
              href='{{settings.button_link}}'
              target='{{settings.button_target}}'
            >{{i18n (themePrefix "announcement_bar.button")}}
            </a>
          </div>
          <div class='announcement-bar__close'>
            <a {{on 'click' this.dismiss}}>
              {{icon 'xmark'}}
            </a>
          </div>
        </div>
      </div>
    {{/if}}
  </template>

  get showOnRoute() {
    const currentRoute = this.router.currentRouteName;
    switch (settings.show_on) {
      case 'everywhere':
        return !currentRoute.includes('admin');
      case 'homepage':
        return currentRoute === `discovery.${defaultHomepage()}`;
      case 'latest/top/new/categories':
        const topMenu = this.siteSettings.top_menu;
        const targets = topMenu.split('|').map((opt) => `discovery.${opt}`);
        return targets.includes(currentRoute);
      default:
        return false;
    }
  }

  get showOnMobile() {
    if (settings.hide_on_mobile && this.site.mobileView) {
      return false;
    } else {
      return true;
    }
  }

  @action
  dismiss() {
    this.keyValueStore.set({ key: this.storageKey, value: 'true' });
    this.dismissed = true;
  }
}
