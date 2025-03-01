import { Response, Router } from "express";
import { auth, AuthRequest } from "../middleware/auth";
import Data from "../models/dataModels";

const dataRouter = Router();

/**
 * Create Default Settings (Only Once)
 * Creates a document with default values for a user (if not already created).
 */
dataRouter.post("/create-defaults", auth, async (req: AuthRequest, res) => {
    try {
        const userId = req.user;
        console.log("Data Route hitted");

        // Check if settings already exist for the user
        const existingData = await Data.findOne({ userId });
        if (existingData) {
            res.status(200).json({ message: "Defaults already exist" });
            return;
        }

        // Create a new document with default values
        await Data.create({ userId });

        res.status(201).json({ message: "Default settings created successfully" });
    } catch (e) {
        console.error("Error creating default settings:", e);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

/**
 * Fetch Requested Keys
 * Returns only the requested keys (from stored or default values).
 */
dataRouter.get("/get", auth, async (req: AuthRequest, res) => {
    try {
        const userId = req.user;
        const requestedKeys: string[] = req.body.keys || [];

        // Fetch user settings
        const existingData: any = await Data.findOne({ userId });

        // Prepare response with requested keys
        let responseData: Record<string, any> = {};
        requestedKeys.forEach((key) => {
            responseData[key] = existingData ? existingData[key] : Data.schema.path(key).options.default;
        });

        res.status(200).json({ message: "Settings fetched successfully", data: responseData });
    } catch (e) {
        console.error("Error fetching settings:", e);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

/**
 * Update Specific Keys
 * Updates only the specified keys without modifying others.
 */
dataRouter.patch("/update", auth, async (req: AuthRequest, res) => {
    try {
        console.log("ROute Hitted")
        const userId = req.user;
        const updateData = req.body;

        // Update only provided keys using $set
        const existingData = await Data.findOneAndUpdate(
            { userId },
            { $set: updateData },
            { new: true, upsert: true }
        );

        res.status(200).json({ message: "Settings updated successfully", data: existingData });
    } catch (e) {
        console.error("Error updating settings:", e);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

export default dataRouter; // Export the router to use it in other files