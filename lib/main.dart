import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './models/transaction.dart';
import './widgets/chart.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations(
  //   [
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //   ],
  // );
  runApp(MyApp());
}

class MyHome extends StatefulWidget {
  // const MyHome({ Key? key }) : super(key: key);

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final List<Transaction> _userTransactions = [];
  void _addTransaction(
    String txTitle,
    double txAmount,
    DateTime chosenDate,
  ) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddingTx(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      //enableDrag: true,
      isScrollControlled: true,
      builder: (_) {
        return NewTransaction(_addTransaction);
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Transaction> get _recentTransaction {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  bool _showChart = false;

  List<Widget> _buildLandscape(AppBar appBar, Widget txList) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Show Chart'),
          Switch.adaptive(
              activeColor: Theme.of(context).primaryColor,
              value: _showChart,
              onChanged: (val) {
                setState(() {
                  _showChart = val;
                });
              }),
        ],
      ),
      _showChart
          ? Container(
              height: (MediaQuery.of(context).size.height -
                      appBar.preferredSize.height -
                      MediaQuery.of(context).padding.top) *
                  0.7,
              child: Chart(_recentTransaction),
            )
          : txList
    ];
  }

  List<Widget> _buildPortrait(AppBar appBar, Widget txList) {
    return [
      Container(
        height: (MediaQuery.of(context).size.height -
                appBar.preferredSize.height -
                MediaQuery.of(context).padding.top) *
            0.3,
        child: Chart(_recentTransaction),
      ),
      txList,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final dynamic appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: const Text('Expenses App'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  child: Icon(
                    CupertinoIcons.add,
                  ),
                  onTap: () {
                    _startAddingTx(context);
                  },
                )
              ],
            ),
          )
        : AppBar(
            title: Text(
              'Expenses App',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  _startAddingTx(context);
                },
                iconSize: 40,
                tooltip: 'Add Transaction',
              ),
            ],
            backgroundColor: Colors.teal,
          );
    final txList = Container(
      height: (MediaQuery.of(context).size.height -
              appBar.preferredSize.height -
              MediaQuery.of(context).padding.top) *
          0.7,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (isLandscape) ..._buildLandscape(appBar, txList),
            if (!isLandscape) ..._buildPortrait(appBar, txList),
            if (!isLandscape) ..._buildPortrait(appBar, txList),
            if (isLandscape) ..._buildLandscape(appBar, txList),
          ],
        ),
      ),
    );
    return MaterialApp(
      title: 'Expenses App',
      home: Platform.isIOS
          ? CupertinoPageScaffold(
              child: pageBody,
              navigationBar: appBar,
            )
          : Scaffold(
              appBar: appBar,
              backgroundColor: Colors.teal[50],
              body: pageBody,
              floatingActionButton: Platform.isIOS
                  ? Container()
                  : FloatingActionButton(
                      backgroundColor: Colors.teal,
                      child: const Icon(
                        Icons.arrow_upward,
                        size: 20,
                      ),
                      tooltip: 'Add Transaction',
                      onPressed: () {
                        _startAddingTx(context);
                      },
                    ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            ),
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.white,
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'Expenses App',
      home: MyHome(),
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.white,
      ),
    );
  }
}
