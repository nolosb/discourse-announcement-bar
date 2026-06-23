import { apiInitializer } from "discourse/lib/api";
import AnnouncementBar from "../components/announcement-bar";

export default apiInitializer((api) => {
  api.renderInOutlet(settings.plugin_outlet.trim(), AnnouncementBar);
});
