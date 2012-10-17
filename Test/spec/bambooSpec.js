describe( "Bamboo Library", function () {
	
	var testData = {};
	testData["id"] = "1cece817bae04825874669c815f33f99";
	testData["CSVFile"] = "https://www.dropbox.com/s/0m8smn04oti92gr/sample_dataset_school_survey.csv?dl=1";
	testData["localFile"] = "./testData/sample_dataset_school_survey.csv";
	testData["dataSet"] = [{"grade": 4, "sex": "F", "name": "Student10", "income": 60}, {"grade": 2, "sex": "M", "name": "Student5", "income": 50}, {"grade": 4, "sex": "M", "name": "Student13", "income": 70}, {"grade": 3, "sex": "F", "name": "Student3", "income": 50}, {"grade": 2, "sex": "M", "name": "Student6", "income": 60}, {"grade": 4, "sex": "F", "name": "Student7", "income": 50}, {"grade": 3, "sex": "F", "name": "Student4", "income": 50}, {"grade": 4, "sex": "F", "name": "Student12", "income": 70}, {"grade": 4, "sex": "F", "name": "Student9", "income": 50}, {"grade": 4, "sex": "F", "name": "Student8", "income": 50}, {"grade": 1, "sex": "M", "name": "Student1", "income": 30}, {"grade": 4, "sex": "F", "name": "Student11", "income": 60}, {"grade": 1, "sex": "M", "name": "Student14", "income": 20}, {"grade": 2, "sex": "M", "name": "Student2", "income": 50}];

	describe( "Test Constructor", function () {

		it("construct with urlToCSVFile", function () {
			bambooSet = new bamboo.Dataset({ url: testData.CSVFile });
			expect(bambooSet.id).not.toEqual(null);
		});

		it("construct with bambooID", function () {
			bambooSet = new bamboo.Dataset({ id: testData.id });
			expect(bambooSet.id).not.toEqual(null);
		});

		it("construct with pathToLocalFile", function () {
			bambooSet = new bamboo.Dataset({ path: testData.localFile });
			expect(bambooSet.id).not.toEqual(null);
		});
	});

	testData["getData"] = [];
	var test = {};
	test["columns"] = ["grade"];
	test["result"] = [{"grade": 4}, {"grade": 2}, {"grade": 4}, {"grade": 3}, {"grade": 2}, {"grade": 4}, {"grade": 3}, {"grade": 4}, {"grade": 4}, {"grade": 4}, {"grade": 1}, {"grade": 4}, {"grade": 1}, {"grade": 2}];
	testData["getData"].push(test);
	var test = {};
	test["columns"] = ["name", "grade", "sex"];
	test["result"] = [{"grade": 4, "sex": "F", "name": "Student10"}, {"grade": 2, "sex": "M", "name": "Student5"}, {"grade": 4, "sex": "M", "name": "Student13"}, {"grade": 3, "sex": "F", "name": "Student3"}, {"grade": 2, "sex": "M", "name": "Student6"}, {"grade": 4, "sex": "F", "name": "Student7"}, {"grade": 3, "sex": "F", "name": "Student4"}, {"grade": 4, "sex": "F", "name": "Student12"}, {"grade": 4, "sex": "F", "name": "Student9"}, {"grade": 4, "sex": "F", "name": "Student8"}, {"grade": 1, "sex": "M", "name": "Student1"}, {"grade": 4, "sex": "F", "name": "Student11"}, {"grade": 1, "sex": "M", "name": "Student14"}, {"grade": 2, "sex": "M", "name": "Student2"}];
	testData["getData"].push(test);

	describe( "Test getData", function () {		

		it("getData for one column", function () {
			bambooSet = new bamboo.Dataset({ id: testData.id });
			expect(bambooSet.getData(testData["getData"][0].columns)).toEqual(testData["getData"][0].result);
		});

		it("getData for several column", function () {
			bambooSet = new bamboo.Dataset({ id: testData.id });
			expect(bambooSet.getData(testData["getData"][1].columns)).toEqual(testData["getData"][1].result);
		});
	});

	testData["calculation"] = [];
	var test = {};
	test["columnName"] = "salary";
	test["formula"] = "salary=income/12";
	test["result"] = [{"salary": 5.833333333333333}, {"salary": 1.6666666666666667}, {"salary": 4.166666666666667}, {"salary": 4.166666666666667}, {"salary": 5.0}, {"salary": 5.833333333333333}, {"salary": 4.166666666666667}, {"salary": 5.0}, {"salary": 2.5}, {"salary": 5.0}, {"salary": 4.166666666666667}, {"salary": 4.166666666666667}, {"salary": 4.166666666666667}, {"salary": 4.166666666666667}];
	testData["calculation"].push(test);
	var test = {};
	test["columnName"] = "factor_grade_by_income";
	test["formula"] = "factor_grade_by_income=grade*income";
	test["result"] =  [{"factor_grade_by_income": 30.0}, {"factor_grade_by_income": 100.0}, {"factor_grade_by_income": 150.0}, {"factor_grade_by_income": 200.0}, {"factor_grade_by_income": 280.0}, {"factor_grade_by_income": 20.0}, {"factor_grade_by_income": 240.0}, {"factor_grade_by_income": 100.0}, {"factor_grade_by_income": 200.0}, {"factor_grade_by_income": 120.0}, {"factor_grade_by_income": 280.0}, {"factor_grade_by_income": 150.0}, {"factor_grade_by_income": 200.0}, {"factor_grade_by_income": 240.0}];
	testData["calculation"].push(test);

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

	testData["aggregation"] = [];
	var test = {};
	test["columnName"] = "income_ratio";
	test["formula"] = "income_ratio=sum(income)";
	test["group"] = [];
	test["result"] = [{"income_ratio": 720.0}];
	testData["aggregation"].push(test);
	var test = {};
	test["columnName"] = "income_ratio";
	test["formula"] = "income_ratio=sum(income)";
	test["group"] = ["sex"];
	test["result"] = [{"income_ratio": 440.0, "sex": "F"}, {"income_ratio": 280.0, "sex": "M"}];
	testData["aggregation"].push(test);
	var test = {};
	test["columnName"] = "income_ratio";
	test["formula"] = "income_ratio=sum(income)";
	test["group"]=["sex,grade"];
	test["result"] = [{"grade": 3, "income_ratio": 100.0, "sex": "F"}, {"grade": 1, "income_ratio": 50.0, "sex": "M"}, {"grade": 4, "income_ratio": 340.0, "sex": "F"}, {"grade": 2, "income_ratio": 160.0, "sex": "M"}, {"grade": 4, "income_ratio": 70.0, "sex": "M"}];
	testData["aggregation"].push(test);

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
			expect(aggSet.getData(testData["aggregation"][0].groups), testData["aggregation"][0].result);	
			expect(aggSet.getData(testData["aggregation"][1].groups), testData["aggregation"][1].result);	
		});
	});

	describe(" Test Summary", function () {
	});

	describe(" Test Info", function () {
	});

	describe(" Test UpdateData", function () {
	})
});














