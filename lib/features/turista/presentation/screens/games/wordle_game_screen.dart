import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../../../../../core/theme/app_theme.dart';

class WordleGameScreen extends StatefulWidget {
  const WordleGameScreen({super.key});

  @override
  State<WordleGameScreen> createState() => _WordleGameScreenState();
}

class _WordleGameScreenState extends State<WordleGameScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  Map<String, dynamic>? _targetWordDoc;
  String _targetWord = '';
  int _wordLength = 5;
  int _maxAttempts = 6;
  
  List<String> _guesses = [];
  String _currentGuess = '';
  bool _isLoading = true;
  bool _isGameOver = false;
  bool _hasWon = false;

  final List<List<Color>> _keyColors = List.generate(
    3,
    (index) => List.filled(10, Colors.grey[300]!), // Simplification for keyboard state
  );

  final List<String> _keyboardRow1 = ['Q','W','E','R','T','Y','U','I','O','P'];
  final List<String> _keyboardRow2 = ['A','S','D','F','G','H','J','K','L','Ñ'];
  final List<String> _keyboardRow3 = ['ENTER','Z','X','C','V','B','N','M','DEL'];
  
  final Map<String, Color> _letterColors = {};

  @override
  void initState() {
    super.initState();
    _fetchRandomWord();
  }

  Future<void> _fetchRandomWord() async {
    try {
      final snapshot = await _db.collection('wordle_words').where('isActive', isEqualTo: true).get();
      if (snapshot.docs.isNotEmpty) {
        final docs = snapshot.docs;
        final randomDoc = docs[Random().nextInt(docs.length)];
        
        setState(() {
          _targetWordDoc = randomDoc.data();
          _targetWord = (_targetWordDoc!['word'] as String).toUpperCase();
          _wordLength = _targetWord.length;
          _maxAttempts = max(6, _wordLength + 1);
          _isLoading = false;
        });
      } else {
        // Fallback if no words
        setState(() {
          _targetWord = 'CACAO';
          _wordLength = 5;
          _maxAttempts = 6;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _targetWord = 'CACAO';
        _wordLength = 5;
      });
    }
  }

  void _onKeyPress(String key) {
    if (_isGameOver) return;

    setState(() {
      if (key == 'ENTER') {
        if (_currentGuess.length == _wordLength) {
          _submitGuess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La palabra está incompleta'), duration: Duration(milliseconds: 500)),
          );
        }
      } else if (key == 'DEL') {
        if (_currentGuess.isNotEmpty) {
          _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
        }
      } else {
        if (_currentGuess.length < _wordLength) {
          _currentGuess += key;
        }
      }
    });
  }

  void _submitGuess() {
    setState(() {
      _guesses.add(_currentGuess);
      
      // Update keyboard colors
      for (int i = 0; i < _wordLength; i++) {
        String letter = _currentGuess[i];
        if (_targetWord[i] == letter) {
          _letterColors[letter] = Colors.green;
        } else if (_targetWord.contains(letter)) {
          if (_letterColors[letter] != Colors.green) {
            _letterColors[letter] = Colors.amber;
          }
        } else {
          if (_letterColors[letter] != Colors.green && _letterColors[letter] != Colors.amber) {
            _letterColors[letter] = Colors.grey[700]!;
          }
        }
      }

      if (_currentGuess == _targetWord) {
        _isGameOver = true;
        _hasWon = true;
        _handleWin();
      } else if (_guesses.length >= _maxAttempts) {
        _isGameOver = true;
        _hasWon = false;
        _showGameOverDialog();
      }
      
      _currentGuess = '';
    });
  }

  Future<void> _handleWin() async {
    final points = _targetWordDoc?['points'] ?? 10;
    
    // Grant points to the user
    await _db.collection('users').doc(_uid).update({
      'totalPoints': FieldValue.increment(points),
    });
    
    // Add history
    await _db.collection('tourist_wallet_history').add({
      'touristId': _uid,
      'points': points,
      'reason': 'Victoria en Wordle Cultural: $_targetWord',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _showGameOverDialog(pointsEarned: points);
  }

  void _showGameOverDialog({int pointsEarned = 0}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(_hasWon ? '¡Felicidades!' : 'Sigue intentando', style: TextStyle(color: _hasWon ? AppTheme.primary : AppTheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_hasWon ? 'Adivinaste la palabra correctamente.' : 'Se acabaron tus intentos. La palabra era: $_targetWord'),
            const SizedBox(height: 16),
            if (_hasWon)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    const Text('Recompensa obtenida:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('+$pointsEarned Puntos', style: const TextStyle(fontSize: 24, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            if (_targetWordDoc != null && _targetWordDoc!['meaning'] != null && _targetWordDoc!['meaning'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Significado:\n${_targetWordDoc!['meaning']}', style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back to Gamification tab
            },
            child: const Text('Volver'),
          ),
          if (!_hasWon)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _guesses.clear();
                  _currentGuess = '';
                  _isGameOver = false;
                  _hasWon = false;
                  _letterColors.clear();
                  _isLoading = true;
                });
                _fetchRandomWord();
              },
              child: const Text('Jugar de Nuevo'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle Cultural'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.primary,
        actions: [
          if (_targetWordDoc != null && _targetWordDoc!['hint'] != null && _targetWordDoc!['hint'].toString().isNotEmpty)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Pista'),
                    content: Text(_targetWordDoc!['hint']),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido'))],
                  ),
                );
              },
            ),
        ],
      ),
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: _buildGrid(),
                    ),
                  ),
                ),
                _buildKeyboard(),
              ],
            ),
    );
  }

  Widget _buildGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(_maxAttempts, (rowIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_wordLength, (colIndex) {
              String letter = '';
              Color bgColor = Colors.white;
              Color textColor = Colors.black;
              Color borderColor = Colors.grey[400]!;

              if (rowIndex < _guesses.length) {
                // Past guess
                letter = _guesses[rowIndex][colIndex];
                if (_targetWord[colIndex] == letter) {
                  bgColor = Colors.green;
                  borderColor = Colors.green;
                  textColor = Colors.white;
                } else if (_targetWord.contains(letter)) {
                  bgColor = Colors.amber;
                  borderColor = Colors.amber;
                  textColor = Colors.white;
                } else {
                  bgColor = Colors.grey[600]!;
                  borderColor = Colors.grey[600]!;
                  textColor = Colors.white;
                }
              } else if (rowIndex == _guesses.length && colIndex < _currentGuess.length) {
                // Current guess
                letter = _currentGuess[colIndex];
                borderColor = AppTheme.primary;
              }

              // Responsive cell size
              double cellSize = (MediaQuery.of(context).size.width - 32 - (_wordLength * 8)) / _wordLength;
              if (cellSize > 60) cellSize = 60; // Max size

              return Container(
                width: cellSize,
                height: cellSize,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: cellSize * 0.5,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      color: AppTheme.surfaceContainerLowest,
      child: Column(
        children: [
          _buildKeyboardRow(_keyboardRow1),
          const SizedBox(height: 8),
          _buildKeyboardRow(_keyboardRow2),
          const SizedBox(height: 8),
          _buildKeyboardRow(_keyboardRow3),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        Color bgColor = _letterColors[key] ?? Colors.grey[200]!;
        Color textColor = _letterColors.containsKey(key) ? Colors.white : Colors.black87;
        
        double width = MediaQuery.of(context).size.width / 11;
        if (key == 'ENTER' || key == 'DEL') {
          width = width * 1.5;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => _onKeyPress(key),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: width,
                height: 48,
                alignment: Alignment.center,
                child: Text(
                  key,
                  style: TextStyle(
                    fontSize: key.length > 1 ? 12 : 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
