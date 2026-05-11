const bcrypt = require('bcryptjs');
const { User } = require('../models');
const { generateToken, JWT_SECRET } = require('../middleware/auth');
const jwt = require('jsonwebtoken');

exports.signup = async (req, res, next) => {
  try {
    const { username, email, password, phone, location } = req.body;

    // Validate required fields
    if (!username || !email || !password) {
      return res.status(400).json({ success: false, code: 400, message: 'Username, email, and password are required', data: null });
    }

    // Check if user already exists
    const existingUser = await User.findOne({
      where: { email },
    });

    if (existingUser) {
      return res.status(409).json({ success: false, code: 409, message: 'Email already registered', data: null });
    }

    const existingUsername = await User.findOne({
      where: { username },
    });

    if (existingUsername) {
      return res.status(409).json({ success: false, code: 409, message: 'Username already taken', data: null });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await User.create({
      username,
      email,
      password_hash: hashedPassword,
      phone,
      location,
    });

    // Generate token
    const token = generateToken(user.user_id);

    const response = user.toJSON();
    delete response.password_hash;

    res.status(201).json({ success: true, code: 201, message: 'User created successfully', data: { token, user: response } });
  } catch (err) {
    next(err);
  }
};

exports.signin = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ success: false, code: 400, message: 'Email and password are required', data: null });
    }

    // Find user by email
    const user = await User.findOne({
      where: { email },
    });

    if (!user) {
      return res.status(401).json({ success: false, code: 401, message: 'Invalid email or password', data: null });
    }

    // Compare passwords
    const passwordMatch = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatch) {
      return res.status(401).json({ success: false, code: 401, message: 'Invalid email or password', data: null });
    }

    // Generate token
    const token = generateToken(user.user_id);

    const response = user.toJSON();
    delete response.password_hash;

    res.status(200).json({ success: true, code: 200, message: 'Sign in successful', data: { token, user: response } });
  } catch (err) {
    next(err);
  }
};

exports.getProfile = async (req, res, next) => {
  try {
    const user = await User.findByPk(req.userId, {
      attributes: { exclude: ['password_hash'] },
    });

    if (!user) {
      return res.status(404).json({ success: false, code: 404, message: 'User not found', data: null });
    }

    res.status(200).json({ success: true, code: 200, message: 'OK', data: user });
  } catch (err) {
    next(err);
  }
};

exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ success: false, code: 400, message: 'Email is required', data: null });
    const { generateAndSendOtp } = require('../services/otpService');
    try {
      await generateAndSendOtp(email);
      return res.status(200).json({ success: true, code: 200, message: 'OTP sent', data: null });
    } catch (err) {
      if (err.message === 'User not found') return res.status(404).json({ success: false, code: 404, message: 'User not found', data: null });
      throw err;
    }
  } catch (err) {
    next(err);
  }
};

exports.verifyOtp = async (req, res, next) => {
  try {
    const { email, code } = req.body;
    if (!email || !code) return res.status(400).json({ success: false, code: 400, message: 'Email and code are required', data: null });
    const { verifyOtp } = require('../services/otpService');
    const result = await verifyOtp(email, code);
    if (!result) return res.status(400).json({ success: false, code: 400, message: 'OTP invalid or expired', data: null });
    return res.status(200).json({ success: true, code: 200, message: 'OTP verified', data: result });
  } catch (err) {
    next(err);
  }
};

exports.resetPassword = async (req, res, next) => {
  try {
    const { resetToken, password } = req.body;

    if (!resetToken || !password) {
      return res.status(400).json({ success: false, code: 400, message: 'Reset token and password are required', data: null });
    }

    if (password.length < 6) {
      return res.status(400).json({ success: false, code: 400, message: 'Password must be at least 6 characters', data: null });
    }

    let payload;
    try {
      payload = jwt.verify(resetToken, JWT_SECRET);
    } catch (err) {
      return res.status(401).json({ success: false, code: 401, message: 'Reset token invalid or expired', data: null });
    }

    if (!payload || payload.purpose !== 'reset' || !payload.email) {
      return res.status(401).json({ success: false, code: 401, message: 'Reset token invalid or expired', data: null });
    }

    const user = await User.findOne({ where: { email: payload.email } });
    if (!user) {
      return res.status(404).json({ success: false, code: 404, message: 'User not found', data: null });
    }

    user.password_hash = await bcrypt.hash(password, 10);
    await user.save();

    return res.status(200).json({ success: true, code: 200, message: 'Password reset successfully', data: null });
  } catch (err) {
    next(err);
  }
};

exports.logout = async (req, res, next) => {
  try {
    const { blacklistToken } = require('../services/tokenBlacklist');
    const token = req.token || (req.headers.authorization || '').split(' ')[1];
    if (!token) return res.status(400).json({ success: false, code: 400, message: 'No token provided', data: null });
    const jwt = require('jsonwebtoken');
    const { JWT_SECRET } = require('../middleware/auth');
    let ttl = 24 * 3600; // default 24h
    try {
      const decoded = jwt.decode(token);
      if (decoded && decoded.exp) {
        const nowSec = Math.floor(Date.now() / 1000);
        ttl = Math.max(0, decoded.exp - nowSec);
      }
    } catch (e) {}
    blacklistToken(token, ttl);
    return res.status(200).json({ success: true, code: 200, message: 'Logged out', data: null });
  } catch (err) {
    next(err);
  }
};

exports.googleAuth = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ success: false, code: 400, message: 'idToken is required', data: null });
    const { verifyIdToken } = require('../services/googleAuthService');
    const payload = await verifyIdToken(idToken);
    if (!payload || !payload.email) return res.status(400).json({ success: false, code: 400, message: 'Invalid Google token', data: null });

    // Check if user exists
    let user = await User.findOne({ where: { email: payload.email } });

    if (!user) {
      // create user
      user = await User.create({
        username: payload.name ? payload.name.replace(/\s+/g, '').toLowerCase() : payload.email.split('@')[0],
        email: payload.email,
        password_hash: '',
        image: payload.picture || null,
      });
    }

    const token = generateToken(user.user_id);
    const response = user.toJSON();
    delete response.password_hash;
    res.status(200).json({ success: true, code: 200, message: 'Sign in with Google successful', data: { token, user: response } });
  } catch (err) {
    if (err.message && err.message.includes('configured')) return res.status(500).json({ success: false, code: 500, message: 'Google OAuth not configured on server', data: null });
    next(err);
  }
};
