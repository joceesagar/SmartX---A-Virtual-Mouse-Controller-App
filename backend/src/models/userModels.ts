import { Schema } from "mongoose";

import mongoose from 'mongoose';


// Define the TypeScript interface for the User document
interface IUser extends Document {
    username: string;
    email: string;
    password: string;
    createdAt?: Date;
    updatedAt?: Date;
  }

const userSchema:Schema<IUser> = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      trim: true,
      unique: true,
      lowercase: true,
      minlength: [3, 'Username must be at least 3 characters long'],
    },
    email: {
      type: String,
      required: true,
      trim: true,
      unique: true,
      lowercase: true,
      validate: {
        validator: (value:string) =>
          /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(value),
        message: 'Please enter a valid email address',
      },
    },
    password: {
      type: String,
      required: true,
      minlength: [8, 'Password must be at least 8 characters long'],
    },
  },
  { timestamps: true } // Enable automatic createdAt and updatedAt fields
);

const User = mongoose.model('User', userSchema);
export default User;


