describe( "Bamboo Library", function () {

    testData = {
        id : "1cece817bae04825874669c815f33f99",
        CSVFile : "https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv?dl=1",
        localFile : "./testData/sample_dataset_school_survey.csv",
        dataSet : [{"grade": 4, "sex": "F", "name": "Student10", "income": 60}, 
                    {"grade": 2, "sex": "M", "name": "Student5", "income": 50}, 
                    {"grade": 4, "sex": "M", "name": "Student13", "income": 70}, 
                    {"grade": 3, "sex": "F", "name": "Student3", "income": 50}, 
                    {"grade": 2, "sex": "M", "name": "Student6", "income": 60}, 
                    {"grade": 4, "sex": "F", "name": "Student7", "income": 50}, 
                    {"grade": 3, "sex": "F", "name": "Student4", "income": 50}, 
                    {"grade": 4, "sex": "F", "name": "Student12", "income": 70}, 
                    {"grade": 4, "sex": "F", "name": "Student9", "income": 50}, 
                    {"grade": 4, "sex": "F", "name": "Student8", "income": 50}, 
                    {"grade": 1, "sex": "M", "name": "Student1", "income": 30}, 
                    {"grade": 4, "sex": "F", "name": "Student11", "income": 60}, 
                    {"grade": 1, "sex": "M", "name": "Student14", "income": 20}, 
                    {"grade": 2, "sex": "M", "name": "Student2", "income": 50}]
    };

    describe( "Test Constructor", function () {

        it("construct with urlToCSVFile", function () {
            bambooSet = new bamboo.Dataset({ url: testData.CSVFile });
			expect(bambooSet.id).toBeDefined();
            // perform some real operation (like info()) to make sure object created properly
        });

        it("construct with bambooID", function () {
            bambooSet = new bamboo.Dataset({ url: testData.CSVFile });
            firstID = bambooSet.id;
            expect(firstID).toBeDefined();
            console.log(firstID);
            bambooSet2 = new bamboo.Dataset({ id: firstID });
            expect(bambooSet2.id).toEqual(firstID);
            console.log(bambooSet2)
            // compare some server result (like info()) to make sure object created properly 
        });

        it("construct with pathToLocalFile", function () {
            bam = new bamboo();
            bambooSet = bam.Dataset({ path: testData.localFile });
            expect(bambooSet.id).toBeDefined();
            // perform some real operation (like info()) to make sure object created properly
        });
    });

    testData['getData'] = [{
        columns: ["grade"],
        result: [{"grade": 4}, {"grade": 2}, {"grade": 4}, {"grade": 3}, 
                 {"grade": 2}, {"grade": 4}, {"grade": 3}, {"grade": 4}, 
                 {"grade": 4}, {"grade": 4}, {"grade": 1}, {"grade": 4},
                 {"grade": 1}, {"grade": 2}]
        }, {
        columns: ["name", "grade", "sex"],
        result: [{"grade": 4, "sex": "F", "name": "Student10"}, 
                 {"grade": 2, "sex": "M", "name": "Student5"}, 
                 {"grade": 4, "sex": "M", "name": "Student13"},
                 {"grade": 3, "sex": "F", "name": "Student3"},
                 {"grade": 2, "sex": "M", "name": "Student6"}, 
                 {"grade": 4, "sex": "F", "name": "Student7"}, 
                 {"grade": 3, "sex": "F", "name": "Student4"}, 
                 {"grade": 4, "sex": "F", "name": "Student12"}, 
                 {"grade": 4, "sex": "F", "name": "Student9"},
                 {"grade": 4, "sex": "F", "name": "Student8"},
                 {"grade": 1, "sex": "M", "name": "Student1"}, 
                 {"grade": 4, "sex": "F", "name": "Student11"}, 
                 {"grade": 1, "sex": "M", "name": "Student14"},
                 {"grade": 2, "sex": "M", "name": "Student2"}]
    }];

    describe( "Test getData", function () {        

        it("getData for one column", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            var testObj = testData["getData"][0];
            expect(bambooSet.getData(testObj.columns)).toEqual(testObj.result);
        });

        it("getData for several columns", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            var testObj = testData["getData"][1];
            expect(bambooSet.getData(testObj.columns)).toEqual(testObj.result);
        });
    });

    testData["calculation"] = [{
        columnName : "salary",
        formula : "salary=income/12",
        result : [{"salary": 5.833333333333333}, {"salary": 1.6666666666666667},
                  {"salary": 4.166666666666667}, {"salary": 4.166666666666667}, 
                  {"salary": 5.0}, {"salary": 5.833333333333333}, 
                  {"salary": 4.166666666666667}, {"salary": 5.0}, {"salary": 2.5},
                  {"salary": 5.0}, {"salary": 4.166666666666667}, 
                  {"salary": 4.166666666666667}, {"salary": 4.166666666666667}, 
                  {"salary": 4.166666666666667}]
        }, {
        columnName : "factor_grade_by_income",
        formula : "factor_grade_by_income=grade*income",
        result : [{"factor_grade_by_income": 30.0}, {"factor_grade_by_income": 100.0},
                  {"factor_grade_by_income": 150.0}, {"factor_grade_by_income": 200.0},
                  {"factor_grade_by_income": 280.0}, {"factor_grade_by_income": 20.0},
                  {"factor_grade_by_income": 240.0}, {"factor_grade_by_income": 100.0},
                  {"factor_grade_by_income": 200.0}, {"factor_grade_by_income": 120.0},
                  {"factor_grade_by_income": 280.0}, {"factor_grade_by_income": 150.0},
                  {"factor_grade_by_income": 200.0}, {"factor_grade_by_income": 240.0}]
    }];

    describe( "Test AddCalculation", function () {
        
        it("add calculation : calculation for one column", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            bambooSet.addCalculation(testData["calculation"][0].formula);
            expect(bammbooSet.getData( testData["calculation"][0].columnName )).toEqual( testData["calculation"][0].result );
        });

        it("add calculation : calculation for two columns", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            bambooSet.addCalculation(testData["calculation"][1].formula);
            expect(bammbooSet.getData( testData["calculation"][1].columnName )).toEqual( testData["calculation"][1].result );
        });
        // NOTE: would need to delete these stray calculations
    });

    describe( "Test RemoveCalculation", function () {

        it("remove calculation : for one column", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            bambooSet.addCalculation(testData["calculation"][0].formula);
            bambooSet.removeCalculation(testData["calculation"][0].columnName);
            expect(bambooSet.getData([testData["calculation"][0].columnName])).toEqual(null);
        });
    });

    describe( "Test GetCalculation", function () {
        // FOR NOW: add Calculations need to be done by external tool
        
        it("get calculation : when calculation dictionary has one column", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            bambooSet.addCalculation(testData["calculation"][0].formula);
            var result = {};
            result[testData["calculation"][0].columnName] = testData["calculation"][0].result;
            expect(bambooSet.getCalculation()).toEqual(result);
        });

        it("get calculation : when calculation dictionary has two columns", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            bambooSet.addCalculation(testData["calculation"][0].formula);
            bambooSet.addCalculation(testData["calculation"][1].formula);
            var result = bambooSet.getCalculation();
            expect(result[testData["calculation"][0].columnName]).toEqual(testData["calculation"][0].result);    
            expect(result[testData["calculation"][1].columnName]).toEqual(testData["calculation"][1].result);    
        });
    
    });
    testData["aggregation"] = [{
        columnName : "income_ratio",
        formula : "income_ratio=sum(income)",
        group : [],
        result : [{"income_ratio": 720.0}]
        } , {
        columnName : "income_ratio",
        formula : "income_ratio=sum(income)",
        group : ["sex"],
        result : [{"income_ratio": 440.0, "sex": "F"}, 
                  {"income_ratio": 280.0, "sex": "M"}]
        } , {
        columnName : "income_ratio",
        formula : "income_ratio=sum(income)",
        group : ["sex,grade"],
        result : [{"grade": 3, "income_ratio": 100.0, "sex": "F"}, 
                  {"grade": 1, "income_ratio": 50.0, "sex": "M"},
                  {"grade": 4, "income_ratio": 340.0, "sex": "F"}, 
                  {"grade": 2, "income_ratio": 160.0, "sex": "M"}, 
                  {"grade": 4, "income_ratio": 70.0, "sex": "M"}]
    }];

    describe(" Test AddAggregation", function () {
        
        it("add aggregation : sum, with none group", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            aggSet = bambooSet.aggregation(testData["aggregation"][0].formula, testData["aggregation"][0].groups);
            expect(aggSet.id).not.toEqual(null);
        });

        it("add aggregation : sum, with one group", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            aggSet = bambooSet.aggregation(testData["aggregation"][1].formula, testData["aggregation"][1].groups);
            expect(aggSet.id).not.toEqual(null);
        });

        it("add aggregation : sum, with multiple groups", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            aggSet = bambooSet.aggregation(testData["aggregation"][2].formula, testData["aggregation"][2].groups);
            expect(aggSet.id).not.toEqual(null);
        });

    });

    describe(" Test RemoveAggregation", function () {
        /* not implemented by Bamboo yet */
    });

    /* NEEDS re-write based on changed Bamboo.js API */
    describe(" Test GetAggregation", function () {
        it("get aggregation : when the aggregation dictionary has one element", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            aggSet = bambooSet.aggregation(testData["aggregation"][0].formula, testData["aggregation"][0].groups);
            expect(aggSet.id).not.toEqual(null);
            expect(aggSet.getData(testData["aggregation"][0].groups), testData["aggregation"][0].result);
        });

        it("get aggregation : when the aggregation dictionary has two elements", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            aggSet = bambooSet.aggregation(testData["aggregation"][0].formula, testData["aggregation"][0].groups);
            aggSet = bambooSet.aggregation(testData["aggregation"][1].formula, testData["aggregation"][1].groups);
            expect(aggSet.id).not.toEqual(null);
            expect(aggSet.getData(testData["aggregation"][0].groups)).toEqual(testData["aggregation"][0].result);    
            expect(aggSet.getData(testData["aggregation"][1].groups)).toEqual(testData["aggregation"][1].result);    
        });
    });

    /* TODO: move this to a more succinct representation; if not into external files */
    testData["summary"] = [{
        columnName: ["name", "sex", "grade", "income"],
        query: {},
        groups: [],
        result: {
            "grade": {
                "summary": {
                    "count": 14.0, 
                    "std": 1.1766968108291043, 
                    "min": 1.0, 
                    "max": 4.0, 
                    "50%": 3.5, 
                    "25%": 2.0, 
                    "75%": 4.0, 
                    "mean": 3.0
                }
            },
            "income": {
                "summary": {
                    "count": 14.0, 
                    "std": 13.506205330054128, 
                    "min": 20.0, 
                    "max": 70.0, 
                    "50%": 50.0, 
                    "25%": 50.0, 
                    "75%": 60.0, 
                    "mean": 51.42857142857143
                }
            }, 
            "name": {
                "summary": {
                    "Student9": 1, 
                    "Student8": 1, 
                    "Student3": 1, 
                    "Student2": 1, 
                    "Student1": 1, 
                    "Student7": 1, 
                    "Student6": 1, 
                    "Student5": 1, 
                    "Student4": 1, 
                    "Student14": 1, 
                    "Student13": 1, 
                    "Student12": 1, 
                    "Student11": 1, 
                    "Student10": 1
                }
            }, 
            "sex": {
                "summary": {
                    "M": 6, 
                    "F": 8
                }
            }
        }} , {
        columnName : ["name", "sex", "grade", "income"],
        query : {"sex": "F"},
        group : [],
        result : {
            "grade": {
                "summary": {
                    "count": 8.0, 
                    "std": 0.46291004988627571, 
                    "min": 3.0, 
                    "max": 4.0, 
                    "50%": 4.0, 
                    "25%": 3.75, 
                    "75%": 4.0, 
                    "mean": 3.75
                }
            }, 
            "sex": {
                "summary": {
                    "F": 8
                }
            }, 
            "name": {
                "summary": {
                    "Student9": 1, 
                    "Student8": 1, 
                    "Student3": 1, 
                    "Student7": 1, 
                    "Student4": 1, 
                    "Student12": 1, 
                    "Student11": 1, 
                    "Student10": 1
                }
            }, 
            "income": {
                "summary": {
                    "count": 8.0, 
                    "std": 7.5592894601845444, 
                    "min": 50.0, 
                    "max": 70.0, 
                    "50%": 50.0, 
                    "25%": 50.0, 
                    "75%": 60.0, 
                    "mean": 55.0
                }
            }
        }} , {
        columnName: ["name", "sex", "grade", "income"],
        query: {},
        group: ["sex"],
        "result": {
            "sex": {
                "M": {
                    "grade": {
                        "summary": {
                            "count": 6.0, 
                            "std": 1.0954451150103321, 
                            "min": 1.0, 
                            "max": 4.0, 
                            "50%": 2.0, 
                            "25%": 1.25, 
                            "75%": 2.0, 
                            "mean": 2.0
                        }
                    },
                    "name": {
                        "summary": {
                            "Student2": 1, 
                            "Student1": 1, 
                            "Student6": 1, 
                            "Student5": 1, 
                            "Student14": 1, 
                            "Student13": 1
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 6.0, 
                            "std": 18.618986725025259, 
                            "min": 20.0, 
                            "max": 70.0, 
                            "50%": 50.0, 
                            "25%": 35.0, 
                            "75%": 57.5, 
                            "mean": 46.666666666666664
                        }
                    }
                }, 
                "F": {
                    "grade": {
                        "summary": {
                            "count": 8.0, 
                            "std": 0.46291004988627571, 
                            "min": 3.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 3.75, 
                            "75%": 4.0, 
                            "mean": 3.75
                        }
                    }, 
                    "name": {
                        "summary": {
                            "Student9": 1, 
                            "Student8": 1, 
                            "Student3": 1, 
                            "Student7": 1, 
                            "Student4": 1, 
                            "Student12": 1, 
                            "Student11": 1, 
                            "Student10": 1
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 8.0, 
                            "std": 7.5592894601845444, 
                            "min": 50.0, 
                            "max": 70.0, 
                            "50%": 50.0, 
                            "25%": 50.0, 
                            "75%": 60.0, 
                            "mean": 55.0
                        }
                    }
                }
            }
    }} , {
    columnName: ["name", "sex", "grade", "income"],
    query: {},
    groups: ["name", "sex"],
    result: {
        "sex,name": {
            "(u'F', u'Student4')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 3.0, 
                        "max": 3.0, 
                        "50%": 3.0, 
                        "25%": 3.0, 
                        "75%": 3.0, 
                        "mean": 3.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 50.0, 
                        "max": 50.0, 
                        "50%": 50.0, 
                        "25%": 50.0, 
                        "75%": 50.0, 
                        "mean": 50.0
                    }
                }
            }, 
            "(u'F', u'Student12')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 4.0, 
                        "max": 4.0, 
                        "50%": 4.0, 
                        "25%": 4.0, 
                        "75%": 4.0, 
                        "mean": 4.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 70.0, 
                        "max": 70.0, 
                        "50%": 70.0, 
                        "25%": 70.0, 
                        "75%": 70.0, 
                        "mean": 70.0
                    }
                }
            }, 
            "(u'M', u'Student5')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 2.0, 
                        "max": 2.0, 
                        "50%": 2.0, 
                        "25%": 2.0, 
                        "75%": 2.0, 
                        "mean": 2.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 50.0, 
                        "max": 50.0, 
                        "50%": 50.0, 
                        "25%": 50.0, 
                        "75%": 50.0, 
                        "mean": 50.0
                    }
                }
            }, 
            "(u'M', u'Student13')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 4.0, 
                        "max": 4.0, 
                        "50%": 4.0, 
                        "25%": 4.0, 
                        "75%": 4.0, 
                        "mean": 4.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 70.0, 
                        "max": 70.0, 
                        "50%": 70.0, 
                        "25%": 70.0, 
                        "75%": 70.0, 
                        "mean": 70.0
                    }
                }
            }, 
            "(u'F', u'Student3')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 3.0, 
                        "max": 3.0, 
                        "50%": 3.0, 
                        "25%": 3.0, 
                        "75%": 3.0, 
                        "mean": 3.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 50.0, 
                        "max": 50.0, 
                        "50%": 50.0, 
                        "25%": 50.0, 
                        "75%": 50.0, 
                        "mean": 50.0
                    }
                }
            }, 
            "(u'M', u'Student1')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 1.0, 
                        "max": 1.0, 
                        "50%": 1.0, 
                        "25%": 1.0, 
                        "75%": 1.0, 
                        "mean": 1.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 30.0, 
                        "max": 30.0, 
                        "50%": 30.0, 
                        "25%": 30.0, 
                        "75%": 30.0, 
                        "mean": 30.0
                    }
                }
            }, 
            "(u'F', u'Student10')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 4.0, 
                        "max": 4.0, 
                        "50%": 4.0, 
                        "25%": 4.0, 
                        "75%": 4.0, 
                        "mean": 4.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 60.0, 
                        "max": 60.0, 
                        "50%": 60.0, 
                        "25%": 60.0, 
                        "75%": 60.0, 
                        "mean": 60.0
                    }
                }
            }, 
            "(u'F', u'Student11')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 4.0, 
                        "max": 4.0, 
                        "50%": 4.0, 
                        "25%": 4.0, 
                        "75%": 4.0, 
                        "mean": 4.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 60.0, 
                        "max": 60.0, 
                        "50%": 60.0, 
                        "25%": 60.0, 
                        "75%": 60.0, 
                        "mean": 60.0
                    }
                }
            }, 
            "(u'F', u'Student8')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 4.0, 
                        "max": 4.0, 
                        "50%": 4.0, 
                        "25%": 4.0, 
                        "75%": 4.0, 
                        "mean": 4.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 50.0, 
                        "max": 50.0, 
                        "50%": 50.0, 
                        "25%": 50.0, 
                        "75%": 50.0, 
                        "mean": 50.0
                    }
                }
            }, 
            "(u'F', u'Student7')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 4.0, 
                        "max": 4.0, 
                        "50%": 4.0, 
                        "25%": 4.0, 
                        "75%": 4.0, 
                        "mean": 4.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 50.0, 
                        "max": 50.0, 
                        "50%": 50.0, 
                        "25%": 50.0, 
                        "75%": 50.0, 
                        "mean": 50.0
                    }
                }
            }, 
            "(u'M', u'Student14')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 1.0, 
                        "max": 1.0, 
                        "50%": 1.0, 
                        "25%": 1.0, 
                        "75%": 1.0, 
                        "mean": 1.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 20.0, 
                        "max": 20.0, 
                        "50%": 20.0, 
                        "25%": 20.0, 
                        "75%": 20.0, 
                        "mean": 20.0
                    }
                }
            }, 
            "(u'F', u'Student9')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 4.0, 
                        "max": 4.0, 
                        "50%": 4.0, 
                        "25%": 4.0, 
                        "75%": 4.0, 
                        "mean": 4.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 50.0, 
                        "max": 50.0, 
                        "50%": 50.0, 
                        "25%": 50.0, 
                        "75%": 50.0, 
                        "mean": 50.0
                    }
                }
            }, 
            "(u'M', u'Student2')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 2.0, 
                        "max": 2.0, 
                        "50%": 2.0, 
                        "25%": 2.0, 
                        "75%": 2.0, 
                        "mean": 2.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 50.0, 
                        "max": 50.0, 
                        "50%": 50.0, 
                        "25%": 50.0, 
                        "75%": 50.0, 
                        "mean": 50.0
                    }
                }
            }, 
            "(u'M', u'Student6')": {
                "grade": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 2.0, 
                        "max": 2.0, 
                        "50%": 2.0, 
                        "25%": 2.0, 
                        "75%": 2.0, 
                        "mean": 2.0
                    }
                }, 
                "income": {
                    "summary": {
                        "count": 1.0, 
                        "std": "null", 
                        "min": 60.0, 
                        "max": 60.0, 
                        "50%": 60.0, 
                        "25%": 60.0, 
                        "75%": 60.0, 
                        "mean": 60.0
                    }
                }
            }
        }
    }}];
    
    testData["summary"] = [{
        columnName: ["name", "sex", "grade", "income"],
        query: [],
        groups: [],
        result: {
            "grade": {
                "summary": {
                    "count": 14.0, 
                    "std": 1.1766968108291043, 
                    "min": 1.0, 
                    "max": 4.0, 
                    "50%": 3.5, 
                    "25%": 2.0, 
                    "75%": 4.0, 
                    "mean": 3.0
                }
            }, 
            "income": {
                "summary": {
                    "count": 14.0, 
                    "std": 13.506205330054128, 
                    "min": 20.0, 
                    "max": 70.0, 
                    "50%": 50.0, 
                    "25%": 50.0, 
                    "75%": 60.0, 
                    "mean": 51.42857142857143
                }
            }, 
            "name": {
                "summary": {
                    "Student9": 1, 
                    "Student8": 1, 
                    "Student3": 1, 
                    "Student2": 1, 
                    "Student1": 1, 
                    "Student7": 1, 
                    "Student6": 1, 
                    "Student5": 1, 
                    "Student4": 1, 
                    "Student14": 1, 
                    "Student13": 1, 
                    "Student12": 1, 
                    "Student11": 1, 
                    "Student10": 1
                }
            }, 
            "sex": {
                "summary": {
                    "M": 6, 
                    "F": 8
                }
            }
        }
    },{
        "columnName": ["name", "sex", "grade", "income"],
        "query": {"sex": "F"},
        "group": [],
        "result": {
            "grade": {
                "summary": {
                    "count": 8.0, 
                    "std": 0.46291004988627571, 
                    "min": 3.0, 
                    "max": 4.0, 
                    "50%": 4.0, 
                    "25%": 3.75, 
                    "75%": 4.0, 
                    "mean": 3.75
                }
            }, 
            "sex": {
                "summary": {
                    "F": 8
                }
            }, 
            "name": {
                "summary": {
                    "Student9": 1, 
                    "Student8": 1, 
                    "Student3": 1, 
                    "Student7": 1, 
                    "Student4": 1, 
                    "Student12": 1, 
                    "Student11": 1, 
                    "Student10": 1
                }
            }, 
            "income": {
                "summary": {
                    "count": 8.0, 
                    "std": 7.5592894601845444, 
                    "min": 50.0, 
                    "max": 70.0, 
                    "50%": 50.0, 
                    "25%": 50.0, 
                    "75%": 60.0, 
                    "mean": 55.0
                }
            }
        }
    }, {
        "columnName": ["name", "sex", "grade", "income"],
        "query": {},
        "group": ["sex"],
        "result": {
            "sex": {
                "M": {
                    "grade": {
                        "summary": {
                            "count": 6.0, 
                            "std": 1.0954451150103321, 
                            "min": 1.0, 
                            "max": 4.0, 
                            "50%": 2.0, 
                            "25%": 1.25, 
                            "75%": 2.0, 
                            "mean": 2.0
                        }
                    }, 
                    "name": {
                        "summary": {
                            "Student2": 1, 
                            "Student1": 1, 
                            "Student6": 1, 
                            "Student5": 1, 
                            "Student14": 1, 
                            "Student13": 1
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 6.0, 
                            "std": 18.618986725025259, 
                            "min": 20.0, 
                            "max": 70.0, 
                            "50%": 50.0, 
                            "25%": 35.0, 
                            "75%": 57.5, 
                            "mean": 46.666666666666664
                        }
                    }
                }, 
                "F": {
                    "grade": {
                        "summary": {
                            "count": 8.0, 
                            "std": 0.46291004988627571, 
                            "min": 3.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 3.75, 
                            "75%": 4.0, 
                            "mean": 3.75
                        }
                    }, 
                    "name": {
                        "summary": {
                            "Student9": 1, 
                            "Student8": 1, 
                            "Student3": 1, 
                            "Student7": 1, 
                            "Student4": 1, 
                            "Student12": 1, 
                            "Student11": 1, 
                            "Student10": 1
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 8.0, 
                            "std": 7.5592894601845444, 
                            "min": 50.0, 
                            "max": 70.0, 
                            "50%": 50.0, 
                            "25%": 50.0, 
                            "75%": 60.0, 
                            "mean": 55.0
                        }
                    }
                }
            }
        }
    }, {
        "columnName": ["name", "sex", "grade", "income"],
        "query": {},
        "groups": ["name", "sex"],
        "result": {
            "sex,name": {
                "(u'F', u'Student4')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 3.0, 
                            "max": 3.0, 
                            "50%": 3.0, 
                            "25%": 3.0, 
                            "75%": 3.0, 
                            "mean": 3.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 50.0, 
                            "max": 50.0, 
                            "50%": 50.0, 
                            "25%": 50.0, 
                            "75%": 50.0, 
                            "mean": 50.0
                        }
                    }
                }, 
                "(u'F', u'Student12')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 70.0, 
                            "max": 70.0, 
                            "50%": 70.0, 
                            "25%": 70.0, 
                            "75%": 70.0, 
                            "mean": 70.0
                        }
                    }
                }, 
                "(u'M', u'Student5')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 2.0, 
                            "max": 2.0, 
                            "50%": 2.0, 
                            "25%": 2.0, 
                            "75%": 2.0, 
                            "mean": 2.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 50.0, 
                            "max": 50.0, 
                            "50%": 50.0, 
                            "25%": 50.0, 
                            "75%": 50.0, 
                            "mean": 50.0
                        }
                    }
                }, 
                "(u'M', u'Student13')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 70.0, 
                            "max": 70.0, 
                            "50%": 70.0, 
                            "25%": 70.0, 
                            "75%": 70.0, 
                            "mean": 70.0
                        }
                    }
                }, 
                "(u'F', u'Student3')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 3.0, 
                            "max": 3.0, 
                            "50%": 3.0, 
                            "25%": 3.0, 
                            "75%": 3.0, 
                            "mean": 3.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 50.0, 
                            "max": 50.0, 
                            "50%": 50.0, 
                            "25%": 50.0, 
                            "75%": 50.0, 
                            "mean": 50.0
                        }
                    }
                }, 
                "(u'M', u'Student1')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 1.0, 
                            "max": 1.0, 
                            "50%": 1.0, 
                            "25%": 1.0, 
                            "75%": 1.0, 
                            "mean": 1.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 30.0, 
                            "max": 30.0, 
                            "50%": 30.0, 
                            "25%": 30.0, 
                            "75%": 30.0, 
                            "mean": 30.0
                        }
                    }
                }, 
                "(u'F', u'Student10')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 60.0, 
                            "max": 60.0, 
                            "50%": 60.0, 
                            "25%": 60.0, 
                            "75%": 60.0, 
                            "mean": 60.0
                        }
                    }
                }, 
                "(u'F', u'Student11')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 60.0, 
                            "max": 60.0, 
                            "50%": 60.0, 
                            "25%": 60.0, 
                            "75%": 60.0, 
                            "mean": 60.0
                        }
                    }
                }, 
                "(u'F', u'Student8')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 50.0, 
                            "max": 50.0, 
                            "50%": 50.0, 
                            "25%": 50.0, 
                            "75%": 50.0, 
                            "mean": 50.0
                        }
                    }
                }, 
                "(u'F', u'Student7')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null",
                            "min": 50.0, 
                            "max": 50.0, 
                            "50%": 50.0, 
                            "25%": 50.0, 
                            "75%": 50.0, 
                            "mean": 50.0
                        }
                    }
                }, 
                "(u'M', u'Student14')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 1.0, 
                            "max": 1.0, 
                            "50%": 1.0, 
                            "25%": 1.0, 
                            "75%": 1.0, 
                            "mean": 1.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 20.0, 
                            "max": 20.0, 
                            "50%": 20.0, 
                            "25%": 20.0, 
                            "75%": 20.0, 
                            "mean": 20.0
                        }
                    }
                }, 
                "(u'F', u'Student9')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 50.0, 
                            "max": 50.0, 
                            "50%": 50.0, 
                            "25%": 50.0, 
                            "75%": 50.0, 
                            "mean": 50.0
                        }
                    }
                }, 
                "(u'M', u'Student2')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 2.0, 
                            "max": 2.0, 
                            "50%": 2.0, 
                            "25%": 2.0, 
                            "75%": 2.0, 
                            "mean": 2.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 50.0, 
                            "max": 50.0, 
                            "50%": 50.0, 
                            "25%": 50.0, 
                            "75%": 50.0, 
                            "mean": 50.0
                        }
                    }
                }, 
                "(u'M', u'Student6')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 2.0, 
                            "max": 2.0, 
                            "50%": 2.0, 
                            "25%": 2.0, 
                            "75%": 2.0, 
                            "mean": 2.0
                        }
                    }, 
                    "income": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 60.0, 
                            "max": 60.0, 
                            "50%": 60.0, 
                            "25%": 60.0, 
                            "75%": 60.0, 
                            "mean": 60.0
                        }
                    }
                }
            }
        }
    },{
        "columnName": ["grade"],
        "query": {},
        "groups": ["name", "sex"],
        "result": {
            "name,sex": {
                "(u'Student7', u'F')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }
                }, 
                "(u'Student13', u'M')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }
                }, 
                "(u'Student2', u'M')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 2.0, 
                            "max": 2.0, 
                            "50%": 2.0, 
                            "25%": 2.0, 
                            "75%": 2.0, 
                            "mean": 2.0
                        }
                    }
                }, 
                "(u'Student4', u'F')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 3.0, 
                            "max": 3.0, 
                            "50%": 3.0, 
                            "25%": 3.0, 
                            "75%": 3.0, 
                            "mean": 3.0
                        }
                    }
                }, 
                "(u'Student5', u'M')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 2.0, 
                            "max": 2.0, 
                            "50%": 2.0, 
                            "25%": 2.0, 
                            "75%": 2.0, 
                            "mean": 2.0
                        }
                    }
                }, 
                "(u'Student1', u'M')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 1.0, 
                            "max": 1.0, 
                            "50%": 1.0, 
                            "25%": 1.0, 
                            "75%": 1.0, 
                            "mean": 1.0
                        }
                    }
                }, 
                "(u'Student11', u'F')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }
                }, 
                "(u'Student10', u'F')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }
                }, 
                "(u'Student6', u'M')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 2.0, 
                            "max": 2.0, 
                            "50%": 2.0, 
                            "25%": 2.0, 
                            "75%": 2.0, 
                            "mean": 2.0
                        }
                    }
                }, 
                "(u'Student12', u'F')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }
                }, 
                "(u'Student14', u'M')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 1.0, 
                            "max": 1.0, 
                            "50%": 1.0, 
                            "25%": 1.0, 
                            "75%": 1.0, 
                            "mean": 1.0
                        }
                    }
                }, 
                "(u'Student8', u'F')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }
                }, 
                "(u'Student3', u'F')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 3.0, 
                            "max": 3.0, 
                            "50%": 3.0, 
                            "25%": 3.0, 
                            "75%": 3.0, 
                            "mean": 3.0
                        }
                    }
                }, 
                "(u'Student9', u'F')": {
                    "grade": {
                        "summary": {
                            "count": 1.0, 
                            "std": "null", 
                            "min": 4.0, 
                            "max": 4.0, 
                            "50%": 4.0, 
                            "25%": 4.0, 
                            "75%": 4.0, 
                            "mean": 4.0
                        }
                    }
                }
            }
        }
    }];
    
    describe(" Test Summary", function () {
        it("summary : with none query, none group", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            var testObj = testData["summary"][0]; /* TODO: propagate testObj creation through summary tests */
            expect(bambooSet.summary(testObj.columnName, testObj.query, testObj.groups))
                .toEqual(testObj.result);
        });

        it("summary : with one query, none group", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            expect(bambooSet.summary(testData["summary"][1].columnName, testData["summary"][1].query, testData["summary"][1].groups)).toEqual(testData["summary"][1].result);
        });

        it("summary : with none query, one group", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            expect(bambooSet.summary(testData["summary"][2].columnName, testData["summary"][2].query, testData["summary"][2].groups)).toEqual(testData["summary"][2].result);
        });

        it("summary : with none query, multiple groups", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            expect(bambooSet.summary(testData["summary"][3].columnName, testData["summary"][3].query, testData["summary"][3].groups)).toEqual(testData["summary"][3].result);
        });

        it("summary : with one select, multiple groups", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            expect(bambooSet.summary(testData["summary"][4].columnName, testData["summary"][4].query, testData["summary"][4].groups)).toEqual(testData["summary"][4].result);
        });
    });

    testData["info"] = {
        "num_rows": 14, 
        "attribution": "", 
        "description": "", 
        "license": "", 
        "num_columns": 4, 
        "updated_at": 
        "2012-10-12 20:57:41", 
        "created_at": "2012-10-12 20:57:41", 
        "schema": {
            "grade": {
                "olap_type": "measure", 
                "simpletype": "integer", 
                "label": "grade"
            }, 
            "sex": {
                "olap_type": "dimension", 
                "cardinality": 2, 
                "simpletype": "string", 
                "label": "sex"
            }, 
            "name": {
                "olap_type": "dimension", 
                "cardinality": 14, 
                "simpletype": "string", 
                "label": "name"
            }, 
            "income": {
                "olap_type": "measure", 
                "simpletype": "integer", 
                "label": "income"
            }
        }, 
        "id": "1cece817bae04825874669c815f33f99", 
        "label": ""
    }; 
    
    describe(" Test Info", function () {
        it("show info", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            expect(bambooSet.info()).toEqual(testData["info"]);
        });
    });

    testData["update"] = [];
    var test = {};
    test["rows"] = [{"name": "student20", "sex": "M"}];
    test["columns"] = ["name", "sex", "grade", "income"];
    /* TODO: fill in the result, wait for bamboo to fix the error */
    test["result"] = {};
    testData["update"].push(test);
    var test = {};
    test["rows"] = [{"name": "student20", "sex": "M"}, {"name": "student21", "grade": 3, "sex": "F"}];
    test["columns"] = ["name", "sex", "grade", "income"];
    /* TODO: fill in the result, wait for bamboo to fix the error */
    test["result"] = {};
    testData["update"].push(test);

    describe(" Test UpdateData", function () {
        it("updateData : one row", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            bambooSet.updateData(testData["update"][0].rows);
            expect(bambooSet.getColumns(testData["update"][0].columns)).toEqual(testData["update"][0].result);
        });
        it("updateData : multiple rows", function () {
            bambooSet = new bamboo.Dataset({ id: testData.id });
            bambooSet.updateData(testData["update"][0].rows);
            expect(bambooSet.getColumns(testData["update"][0].columns)).toEqual(testData["update"][0].result);
        });
    });

    /* TODO: delete the test datasets in the bamboo server */ 
    
});














