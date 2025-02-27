import mongoose from "mongoose";

function connectToDB(): void {
  const mongoUri = process.env.MONGO_URI;

  if (!mongoUri) {
    console.error("MONGO_URI is not defined in the environment variables.");
    process.exit(1); // Exit the process if the URI is missing
  }

  mongoose
    .connect(mongoUri)
    .then(() => {
      console.log("Connected to DB");
    })
    .catch((err) => {
      console.error("Failed to connect to DB:", err);
      process.exit(1); // Exit if the connection fails
    });
}

export default connectToDB;
