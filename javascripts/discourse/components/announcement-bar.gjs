import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';
import { htmlSafe } from '@ember/template';
import cookie, { removeCookie } from 'discourse/lib/cookie';
import { defaultHomepage } from 'discourse/lib/utilities';
import icon from 'discourse-common/helpers/d-icon';
import and from 'truth-helpers/helpers/and';

export default class AnnouncementBar extends Component {
  @service site;
  @service siteSettings;
  @service router;
  @tracked closed = false;

  <template>
    {{#if (and this.showOnRoute this.showOnMobile this.cookieState)}}
      <div class='announcement-bar__wrapper {{settings.plugin_outlet}}'>
        <div class='announcement-bar__container'>
          <div class='announcement-bar__content'>
            <span>{{htmlSafe settings.bar_text}}</span>
            <a
              class='btn btn-primary'
              href='{{settings.button_link}}'
            >{{settings.button_text}}</a>
          </div>
          <div class='announcement-bar__close'>
            <a {{on 'click' this.closeBanner}}>
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

  get cookieExpirationDate() {
    return moment().add(1, 'year').toDate();
  }

  get cookieState() {
    const closed_cookie = cookie('discourse_announcement_bar_closed');
    if (closed_cookie) {
      const cookieValue = JSON.parse(closed_cookie);
      if (cookieValue.name !== settings.update_version) {
        removeCookie('discourse_announcement_bar_closed', { path: '/' });
      } else {
        this.closed = true;
      }
    }
    return !this.closed;
  }

  @action
  closeBanner() {
    this.closed = true;
    const bannerState = { name: settings.update_version, closed: 'true' };
    cookie('discourse_announcement_bar_closed', JSON.stringify(bannerState), {
      expires: this.cookieExpirationDate,
      path: '/',
    });
  }
}
