const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data, context) => {
    const {token, title, body, payload} = data;

    if (!token) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Token is required",
        );
    }

    const message = {
        token: token,
        notification: {
            title: title || "New Message",
            body: body || "",
        },
        data: payload || {},
        android: {
            priority: "high",
            notification: {
                sound: "default",
            },
        },
        apns: {
            payload: {
                aps: {
                    contentAvailable: true,
                    sound: "default",
                },
            },
        },
    };

    try {
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);
        return {success: true, messageId: response};
    } catch (error) {
        console.error("Error sending message:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});
