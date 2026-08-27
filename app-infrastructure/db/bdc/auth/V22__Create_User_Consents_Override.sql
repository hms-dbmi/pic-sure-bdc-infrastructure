create table consents_override {
    `uuid` binary(16) NOT NULL UNIQUE,
    `name` TEXT NOT NULL UNIQUE,
    `consents` JSON
};

CREATE TABLE user_consents_override (
   `uuid` binary(16) NOT NULL UNIQUE,
   `user_id` binary(16) NOT NULL UNIQUE,
   `consents_override_id` binary(16) NOT NULL,
   `enabled` bit(1) NOT NULL DEFAULT b'1',
   FOREIGN KEY (`user_id`) REFERENCES user(`uuid`)
       ON DELETE CASCADE,
   FOREIGN KEY (`consents_override_id`) REFERENCES consents_override(`uuid`)
);