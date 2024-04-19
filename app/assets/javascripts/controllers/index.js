import { application } from "./application";

import PasswordVisibilityController from "@stimulus-components/password-visibility";
import RevealController from "@stimulus-components/reveal";
import DialogController from "@stimulus-components/dialog";
import SessionController from "./session_controller";
import RecoverController from "./recover_controller";
import RecoverPasswordController from "./recover_password_controller";
import EmailsController from "./emails_controller";
import KeysController from "./keys_controller";
import ThemeController from "./theme_controller";
import TableController from "./table_controller";

application.register("session", SessionController);
application.register("recover", RecoverController);
application.register("recover-password", RecoverPasswordController);
application.register("emails", EmailsController);
application.register("keys", KeysController);
application.register("table", TableController);
application.register("password-visibility", PasswordVisibilityController);
application.register("reveal", RevealController);
application.register("dialog", DialogController);
application.register("theme", ThemeController);
