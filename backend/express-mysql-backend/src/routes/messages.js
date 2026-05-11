const express = require('express');
const router = express.Router();
const messagesController = require('../controllers/messageController');

router.get('/', messagesController.list);
router.get('/sender/:senderId', messagesController.listBySender);
router.get('/receiver/:receiverId', messagesController.listByReceiver);
router.get('/conversation/:userId1/:userId2', messagesController.conversation);
router.post('/', messagesController.create);
router.get('/:id', messagesController.get);
router.put('/:id', messagesController.update);
router.delete('/:id', messagesController.remove);

module.exports = router;
