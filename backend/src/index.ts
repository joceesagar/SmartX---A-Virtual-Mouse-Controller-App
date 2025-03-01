import express from "express";
import authRouter from "./routes/auth";
import dotenv from "dotenv";
import connectToDB from "./config/db";
import dataRouter from "./routes/data";
dotenv.config();
connectToDB()

const app = express();

// Middleware to parse JSON
app.use(express.json());
// Middleware to parse URL-encoded data
app.use(express.urlencoded({ extended: true }))
app.use("/auth", authRouter);
app.use("/data", dataRouter)

app.get("/", (req, res) => {
    res.send("Welcome to my app!!");

});

app.listen(8000, () => {
    console.log("Server is running on port 8000");
})