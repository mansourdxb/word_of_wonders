import 'package:flutter/material.dart';
import '../../models/word.dart';

class WordDisplay extends StatelessWidget {
  final List<Word> foundWords;
  final int totalWords;
  final List<Word> allWords; // Add this to know hidden word lengths
  
  const WordDisplay({
    Key? key,
    required this.foundWords,
    required this.totalWords,
    required this.allWords,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Found Words: ${foundWords.length}/$totalWords',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: totalWords,
              itemBuilder: (context, wordIndex) {
                if (wordIndex < foundWords.length) {
                  // Found word - display as individual letter boxes
                  final word = foundWords[wordIndex].text.toUpperCase();
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    height: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < word.length; i++)
                          Container(
                            width: 40,
                            height: 40,
                            margin: EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              word[i],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  // Hidden word - show question marks based on the actual word length
                  final wordLength = allWords[wordIndex].text.length;
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    height: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        wordLength,
                        (i) => Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}