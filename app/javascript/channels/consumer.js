import { createConsumer } from "@rails/actioncable";
const consumer = createConsumer("ws://web:5000/cable");
export default consumer;
