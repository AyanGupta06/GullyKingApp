import 'package:flutter/material.dart';
import 'package:gully_king/pages/new_unranked_game_page.dart';

class NewBatsmanDialog extends StatelessWidget {
  final List<Player> availableBatsmen;
  final Function(Player) onBatsmanSelected;

  const NewBatsmanDialog({
    Key? key,
    required this.availableBatsmen,
    required this.onBatsmanSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select a New Batsman"),
      content: DropdownButton<Player>(
        hint: const Text("Select Batsman"),
        items: availableBatsmen.map((Player player) {
          return DropdownMenuItem<Player>(
            value: player,
            child: Text(player.name),
          );
        }).toList(),
        onChanged: (Player? selectedPlayer) {
          if (selectedPlayer != null) {
            onBatsmanSelected(selectedPlayer);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
