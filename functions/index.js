const functions = require("firebase-functions");
const admin = require("firebase-admin");
// Import the new v2 syntax for Firestore triggers
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

admin.initializeApp();

const setRoleClaim = async (doc, collectionName) => {
  const userId = doc.id;
  const data = doc.data();
  let role = "user"; // Default role

  if (collectionName === "vendors") {
    role = "vendor";
  } else if (collectionName === "admin") {
    role = "admin";
  }

  if (data.role) {
    role = data.role;
  }

  try {
    await admin.auth().setCustomUserClaims(userId, { role: role });
    console.log(`Successfully set role '${role}' for user ${userId}`);
    return null;
  } catch (error) {
    console.error(`Error setting custom claim for ${userId}:`, error);
    return error;
  }
};

// NEW SYNTAX: Trigger for when a new document is created in 'users'
exports.onUserCreate = onDocumentCreated("users/{userId}", (event) => {
  const snap = event.data;
  if (!snap) {
    console.log("No data associated with the event");
    return;
  }
  return setRoleClaim(snap, "users");
});

// NEW SYNTAX: Trigger for when a new document is created in 'vendors'
exports.onVendorCreate = onDocumentCreated("vendors/{vendorId}", (event) => {
  const snap = event.data;
  if (!snap) {
    console.log("No data associated with the event");
    return;
  }
  return setRoleClaim(snap, "vendors");
});

// NEW SYNTAX: Trigger for when a new document is created in 'admin'
exports.onAdminCreate = onDocumentCreated("admin/{adminId}", (event) => {
  const snap = event.data;
  if (!snap) {
    console.log("No data associated with the event");
    return;
  }
  return setRoleClaim(snap, "admin");
});