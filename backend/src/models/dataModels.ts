import { Schema, model, Document, Types } from 'mongoose';

// Define the TypeScript interface for the Settings document
interface IData extends Document {
    userId: Types.ObjectId;  // Reference to the User model
    type?: string;
    gestureSensitivity?: number;
    hapticOutput?: boolean;
    hapticMode?: number;
    leftClick?: string;
    rightClick?: string;
    doubleClick?: string;
    scrollGesture?: string;
    scrollSpeed?: number;
    deviceName?: string;
    createdAt?: Date;
    updatedAt?: Date;
}

// Define the schema
const dataSchema: Schema<IData> = new Schema(
    {
        userId: {
            type: Schema.Types.ObjectId,
            ref: 'User', // Reference to User model
            required: true,
            unique: true, // Ensures one settings document per user
        },
        type: {
            type: String,
            default: 'N',
        },
        gestureSensitivity: {
            type: Number,
            default: 70,
        },
        hapticOutput: {
            type: Boolean,
            default: true,
        },
        hapticMode: {
            type: Number,
            default: 0,
        },
        leftClick: {
            type: String,
            default: 'Index',
        },
        rightClick: {
            type: String,
            default: 'Ring',
        },
        doubleClick: {
            type: String,
            default: 'Index',
        },
        scrollGesture: {
            type: String,
            default: 'IndexMiddle',
        },
        scrollSpeed: {
            type: Number,
            default: 20.0,
        },
        deviceName: {
            type: String,
            default: 'Default Device',
        },
    },
    { timestamps: true } // Enable createdAt and updatedAt fields
);

// Create and export the model
const Data = model<IData>('Data', dataSchema);
export default Data;
