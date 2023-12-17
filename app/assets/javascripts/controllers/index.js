import { application } from "./application";

import SessionController from "./session_controller";
import RecoverController from "./recover_controller";
import RecoverPasswordController from "./recover_password_controller";
import EmailsController from "./emails_controller";
import KeysController from "./keys_controller";
application.register("session", SessionController);
application.register("recover", RecoverController);
application.register("recover-password", RecoverPasswordController);
application.register("emails", EmailsController);
application.register("keys", KeysController);
