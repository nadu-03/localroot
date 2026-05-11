const { Item, User, Category, Transaction } = require('../models');
const { Op } = require('sequelize');

exports.list = async (req, res, next) => {
  try {
    const { categoryId, status, q } = req.query;
    const where = {};
    if (categoryId) where.category_id = categoryId;
    if (status === 'sold') where.status = 'sold';
    if (status === 'unsold' || status === 'pending') {
      where.status = { [Op.in]: ['active', 'pending'] };
    }
    if (q) {
      where[Op.or] = [
        { title: { [Op.like]: `%${q}%` } },
        { description: { [Op.like]: `%${q}%` } },
      ];
    }

    const items = await Item.findAll({
      where,
      include: [
        { model: User, as: 'seller', attributes: ['user_id', 'username', 'email'] },
        { model: Category, as: 'category' }
      ],
      order: [['created_at', 'DESC']],
    });
    const rows = items.map(formatItemResponse);
    // Keep image fields as stored (data URLs or paths). Frontend can use data URLs directly.
    res.status(200).json({ success: true, code: 200, message: 'OK', data: rows });
  } catch (err) {
    next(err);
  }
};

exports.listBySeller = async (req, res, next) => {
  try {
    const items = await Item.findAll({
      where: { seller_id: req.params.sellerId },
      include: [
        {
          model: User,
          as: 'seller',
          attributes: ['user_id', 'username', 'email'],
        },
        { model: Category, as: 'category' },
      ],
      order: [['created_at', 'DESC']],
    });
    const rows = items.map(formatItemResponse);
    res.status(200).json({ success: true, code: 200, message: 'OK', data: rows });
  } catch (err) {
    next(err);
  }
};

exports.listMyListings = async (req, res, next) => {
  try {
    const statusFilter = buildListingStatusFilter(req.query.status);
    if (!statusFilter) {
      return res.status(400).json({
        success: false,
        code: 400,
        message: 'Status must be one of: sold, pending, unsold',
        data: null,
      });
    }

    const items = await Item.findAll({
      where: {
        seller_id: req.userId,
        status: statusFilter,
      },
      include: [
        {
          model: User,
          as: 'seller',
          attributes: ['user_id', 'username', 'email'],
        },
        { model: Category, as: 'category' },
      ],
      order: [['created_at', 'DESC']],
    });

    const rows = items.map(formatItemResponse);
    res.status(200).json({
      success: true,
      code: 200,
      message: 'OK',
      data: rows,
    });
  } catch (err) {
    next(err);
  }
};

exports.get = async (req, res, next) => {
  try {
    const item = await Item.findByPk(req.params.id, {
      include: [{
        model: User,
        as: 'seller',
        attributes: ['user_id', 'username', 'email'],
      }, { model: Category, as: 'category' }],
    });
    if (!item) return res.status(404).json({ success: false, code: 404, message: 'Item not found', data: null });
    const response = formatItemResponse(item);
    // Return image fields as stored (data URL or path) without writing files.
    res.status(200).json({ success: true, code: 200, message: 'OK', data: response });
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const payload = { ...req.body };
    if (req.file && req.file.buffer) {
      const b64 = req.file.buffer.toString('base64');
      payload.image = `data:${req.file.mimetype};base64,${b64}`;
    }

    // Normalize status value to match model allowed values
    if (payload.status && typeof payload.status === 'string') {
      let s = payload.status.trim().toLowerCase();
      // Remove surrounding quotes if present
      if ((s.startsWith("'") && s.endsWith("'")) || (s.startsWith('"') && s.endsWith('"'))) {
        s = s.slice(1, -1).trim();
      }
      if (s === 'unsold' || s === 'available' || s === 'ok') s = 'active';
      if (!['active', 'pending', 'inactive', 'sold'].includes(s)) {
        delete payload.status; // let default apply
      } else {
        payload.status = s;
      }
    }

    const item = await Item.create(payload);
    const result = await Item.findByPk(item.item_id, {
      include: [
        {
          model: User,
          as: 'seller',
          attributes: ['user_id', 'username', 'email'],
        },
        { model: Category, as: 'category' },
      ],
    });
    res.status(201).json({ success: true, code: 201, message: 'Created', data: formatItemResponse(result) });
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const item = await Item.findByPk(req.params.id);
    if (!item) return res.status(404).json({ success: false, code: 404, message: 'Item not found', data: null });
    const payload = { ...req.body };
    if (req.file && req.file.buffer) {
      const b64 = req.file.buffer.toString('base64');
      payload.image = `data:${req.file.mimetype};base64,${b64}`;
    }
    // Normalize status like in create
    if (payload.status && typeof payload.status === 'string') {
      let s = payload.status.trim().toLowerCase();
      if ((s.startsWith("'") && s.endsWith("'")) || (s.startsWith('"') && s.endsWith('"'))) {
        s = s.slice(1, -1).trim();
      }
      if (s === 'unsold' || s === 'available' || s === 'ok') s = 'active';
      if (!['active', 'pending', 'inactive', 'sold'].includes(s)) {
        delete payload.status;
      } else {
        payload.status = s;
      }
    }

    await item.update(payload);
    const result = await Item.findByPk(req.params.id, {
      include: [
        { model: User, as: 'seller', attributes: ['user_id', 'username', 'email'] },
        { model: Category, as: 'category' }
      ],
    });
    res.status(200).json({ success: true, code: 200, message: 'OK', data: formatItemResponse(result) });
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const item = await Item.findByPk(req.params.id);
    if (!item) return res.status(404).json({ success: false, code: 404, message: 'Item not found', data: null });
    
    await item.destroy();
    res.status(200).json({ success: true, code: 200, message: 'Deleted', data: null });
  } catch (err) {
    next(err);
  }
};

exports.stats = async (req, res, next) => {
  try {
    // total sold items and income from completed transactions
    const totalSold = await Transaction.count({ where: { status: 'completed' } });
    const totalIncomeRow = await Transaction.findAll({
      attributes: [[Transaction.sequelize.fn('SUM', Transaction.sequelize.col('amount')), 'total_income']],
      where: { status: 'completed' },
      raw: true,
    });
    const totalIncome = totalIncomeRow && totalIncomeRow[0] ? parseFloat(totalIncomeRow[0].total_income || 0) : 0;

    // total buy count (transactions with type 'buy' completed)
    const totalBuyCount = await Transaction.count({ where: { status: 'completed', type: 'buy' } });

    res.status(200).json({ success: true, code: 200, message: 'OK', data: { totalSold, totalIncome, totalBuyCount } });
  } catch (err) { next(err); }
};

function buildListingStatusFilter(status) {
  if (!status || typeof status !== 'string') return null;

  const value = status.trim().toLowerCase();
  if (value === 'sold') return 'sold';
  if (value === 'pending' || value === 'unsold' || value === 'active') {
    return { [Op.in]: ['active', 'pending'] };
  }

  return null;
}

function formatItemResponse(item) {
  const data = typeof item.toJSON === 'function' ? item.toJSON() : item;
  const category = data.category;
  const categoryName = category
    ? (category.category_name || category.name || category.title || null)
    : null;

  return {
    ...data,
    category_name: categoryName,
  };
}
