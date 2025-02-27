import { Request, Response, Router } from "express";
import UserModel from "../models/userModels"
import { body, validationResult } from "express-validator";
import bcryptjs from "bcryptjs"
import jwt from "jsonwebtoken"
import { auth, AuthRequest } from "../middleware/auth";


const authRouter = Router();

interface SignUpBody {
    username: string;
    email: string;
    password: string;
}

interface LoginBody {
    usernameOremail: string;
    password: string;
}

// Validation rules
const validateSignup = [
    body("username")
        .trim()
        .notEmpty().withMessage("Please enter a username.")
        .isLength({ min: 3 }).withMessage("Your username must be at least 3 characters long.")
        .isAlphanumeric().withMessage("Your username can only contain letters and numbers."),

    body("email")
        .trim()
        .notEmpty().withMessage("Please enter an email address.")
        .isEmail().withMessage("Please enter a valid email address."),

    body("password")
        .notEmpty().withMessage("Please enter a password.")
        .isLength({ min: 5 }).withMessage("Your password must be at least 5 characters long.")
        .matches(/\d/).withMessage("Your password must include at least one number.")
        .matches(/[a-zA-Z]/).withMessage("Your password must include at least one letter."),
];




// Validation for login
const validateLogin = [

    body("email")
        .trim()
        .notEmpty().withMessage("Please enter an email address.")
        .isEmail().withMessage("Please enter a valid email address."),

    body("password")
        .notEmpty().withMessage("Please enter a password.")
        .isLength({ min: 5 }).withMessage("Your password must be at least 5 characters long.")
        .matches(/\d/).withMessage("Your password must include at least one number.")
        .matches(/[a-zA-Z]/).withMessage("Your password must include at least one letter.")
];



authRouter.post("/signup", validateSignup, async (req: Request<{}, {}, SignUpBody>, res: Response) => {
    const error = validationResult(req);
    if (!error.isEmpty()) {
        res.status(400).json({
            errors: error.array(),
            message: 'Invalid data'
        });
        return;
    }
    try {
        //get req body
        const { username, email, password } = req.body;

        //check if user already exists
        const existingUser = await UserModel.findOne({ $or: [{ username: username }, { email: email }] });
        if (existingUser) {
            res.status(400).json({ message: "User with username or email already exists" });
            return;
        }

        //hash password
        const hashPassword = await bcryptjs.hash(password, 10)

        //create new user and store in the db
        const newUser = await UserModel.create({
            username,
            email,
            password: hashPassword
        })
        res.status(201).json({ message: "User created successfully" });

    } catch (e) {
        res.status(500).json({ error: e });
    }

});



authRouter.post("/login", validateLogin, async (req: Request<{}, {}, SignUpBody>, res: Response) => {
    const error = validationResult(req);
    if (!error.isEmpty()) {
        res.status(400).json({
            errors: error.array(),
            message: 'Invalid username or password'
        });
        return;
    }
    try {
        //get req body
        const { username, email, password } = req.body;

        // Find user by either username or email
        const existingUser = await UserModel.findOne({
            email: email
        });

        if (!existingUser) {
            res.status(400).json({ message: "Invalid Email or Password" });
            return;
        }

        // Check if the entered password matches the hashed password in the database
        const isPasswordValid = await bcryptjs.compare(password, existingUser.password);
        if (!isPasswordValid) {
            res.status(400).json({ message: "Invalid Email or Password" });
            return;
        }

        const SECRET_KEY = process.env.JWT_SECRET;

        if (!SECRET_KEY) {
            throw new Error('SECRET_KEY is not defined in environment variables');
        }

        const token = jwt.sign({ id: existingUser.id }, SECRET_KEY);

        // Return a success message or JWT token (if needed)
        res.status(200).json({ token, message: "Login successful" });


    } catch (e) {
        res.status(500).json({ error: e });
    }

});


authRouter.post("/tokenIsValid", async (req, res) => {
    try {
        //get the header
        const token = req.header("x-auth-token");
        if (!token) {
            res.json(false);
            return;
        }


        //verify if token is valid
        const SECRET_KEY = process.env.JWT_SECRET;

        if (!SECRET_KEY) {
            throw new Error('SECRET_KEY is not defined in environment variables');
        }
        const verified = jwt.verify(token, SECRET_KEY)
        if (!verified) {
            res.json(false);
            return;
        }


        //get the user data if token is valid
        const verifiedToken = verified as { id: String };
        const user = UserModel.findOne({
            _id: verifiedToken.id
        });
        if (!user) {
            res.json(false);
            return;
        }

        res.json(true);
    } catch (e) {
        res.status(500).json(false);
    }

})

authRouter.get("/", auth, async (req: AuthRequest, res) => {
    try {
        if (!req.user) {
            res.status(401).json({ msg: "User not found" });
            return;
        }

        const user = await UserModel.findOne({
            _id: req.user
        })

        res.json({ ...user, token: req.token })
    } catch (e) {
        res.status(500).json(false);
    }
});

export default authRouter;  // export the router