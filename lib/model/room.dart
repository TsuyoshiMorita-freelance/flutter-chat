class Room {
  late String uid;
  late List joined_user_ids;
  late DateTime updated_time;

  Room({required this.uid, required this.joined_user_ids, required this.updated_time});
}