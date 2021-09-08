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
  runApp(MyAp());
}

class MyApp extends StatefulWidget {
  // const MyApp({ Key? key }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Transaction> _userTransactions = [
    // Transaction(
    //   title: 'Agarbatti',
    //   amount: 200.00,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   title: 'Milk',
    //   amount: 66.00,
    //   date: DateTime.now(),
    //   id
    // ),
  ];
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
      builder: (bctx) {
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

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final dynamic appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Expenses App'),
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
    final pageBody = SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isLandscape)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Show Chart'),
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
          if (!isLandscape)
            Container(
              height: (MediaQuery.of(context).size.height -
                      appBar.preferredSize.height -
                      MediaQuery.of(context).padding.top) *
                  0.3,
              child: Chart(_recentTransaction),
            ),
          if (!isLandscape) txList,
          if (isLandscape)
            _showChart
                ? Container(
                    height: (MediaQuery.of(context).size.height -
                            appBar.preferredSize.height -
                            MediaQuery.of(context).padding.top) *
                        0.7,
                    child: Chart(_recentTransaction),
                  )
                : txList
        ],
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
                      child: Icon(
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

class MyAp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'Expenses App',
      home: MyApp(),
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.white,
      ),
    );
  }
}
