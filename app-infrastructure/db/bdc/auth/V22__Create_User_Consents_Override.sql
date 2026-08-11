CREATE TABLE user_consents_override (
   `uuid` binary(16) NOT NULL UNIQUE,
   `user_id` binary(16) NOT NULL UNIQUE,
   `consents` JSON,
   `enabled` bit(1) NOT NULL DEFAULT b'1',
   FOREIGN KEY (`user_id`) REFERENCES user(`uuid`)
       ON DELETE CASCADE
);