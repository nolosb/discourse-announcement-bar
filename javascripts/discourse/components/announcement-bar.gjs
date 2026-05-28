import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';
import { modifier } from 'ember-modifier';
import { defaultHomepage } from 'discourse/lib/utilities';
import icon from 'discourse-common/helpers/d-icon';
import i18n from 'discourse-common/helpers/i18n';
import I18n from 'discourse-i18n';

export default class AnnouncementBar extends Component {
  @service site;
  @service siteSettings;
  @service router;
  @service keyValueStore;
  @tracked dismissed = false;

  detectWrap = modifier((element) => {
    const content = element.querySelector('.announcement-bar__content');
    const observer = new ResizeObserver(() => {
      const wrapped = content.scrollHeight > content.clientHeight;
      element.classList.toggle('--wrapped', wrapped);
    });
    observer.observe(content);
    return () => observer.disconnect();
  });

  get storageKey() {
    return `announcement-bar-dismissed-${I18n.t(
      themePrefix('announcement_bar.text'),
    )}`;
  }

  get isVisible() {
    if (this.dismissed) {
      return false;
    }
    if (settings.hide_on_mobile && this.site.mobileView) {
      return false;
    }
    if (this.keyValueStore.get(this.storageKey)) {
      return false;
    }

    const currentRoute = this.router.currentRouteName;
    switch (settings.show_on) {
      case 'everywhere':
        return !currentRoute.includes('admin');
      case 'homepage':
        return currentRoute === `discovery.${defaultHomepage()}`;
      case 'latest/top/new/categories':
        return this.siteSettings.top_menu
          .split('|')
          .map((opt) => `discovery.${opt}`)
          .includes(currentRoute);
      default:
        return false;
    }
  }

  <template>
    {{#if this.isVisible}}
      <div class='announcement-bar__wrapper {{settings.plugin_outlet}}'>
        <div class='announcement-bar__container' {{this.detectWrap}}>
          <div class='announcement-bar__content'>
            <span class='announcement-bar__text'>{{i18n
                (themePrefix 'announcement_bar.text')
              }}</span>
            <a
              class='announcement-bar__button btn btn-primary'
              href='{{settings.button_link}}'
              target='{{settings.button_target}}'
            >{{i18n (themePrefix 'announcement_bar.button')}}
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

  @action
  dismiss() {
    this.keyValueStore.set({ key: this.storageKey, value: 'true' });
    this.dismissed = true;
  }
}
