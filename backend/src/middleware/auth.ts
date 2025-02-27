import { UUID } from "crypto"
import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken"
import UserModel from "../models/userModels"

export interface AuthRequest extends Request {
    user?: UUID;
    token?: string;
}
export const auth = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        //get the header
        const token = req.header("x-auth-token");
        if (!token) {
            res.status(401).json({ message: "No auth token, access denied!" });
            return;
        }


        //verify if token is valid
        const SECRET_KEY = process.env.JWT_SECRET;

        if (!SECRET_KEY) {
            throw new Error('SECRET_KEY is not defined in environment variables');
        }
        const verified = jwt.verify(token, SECRET_KEY)
        if (!verified) {
            res.status(401).json({ message: "Token Validation Failed" });
            return;
        }


        //get the user data if token is valid
        const verifiedToken = verified as { id: UUID };
        const user = UserModel.findOne({
            _id: verifiedToken.id
        });
        if (!user) {
            res.status(401).json({ message: "User not found" });
            return;
        }

        req.user = verifiedToken.id;
        req.token = token;

        next();
    } catch (e) {
        res.status(500).json(false);
    }

}

