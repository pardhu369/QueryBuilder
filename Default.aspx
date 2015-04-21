<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" href="Content/bootstrap.css" type="text/css" />
    <link rel="stylesheet" href="Content/query-builder.default.css" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="col-md-12 col-lg-10 col-lg-offset-1">
                <div class="page-header">
                    <h1>jQuery QueryBuilder <small>Example</small></h1>
                </div>

                <div id="builder"></div>

                <div class="btn-group">
                    <button class="btn btn-warning reset">Reset</button>
                    <%-- <button class="btn btn-success set">Set rules</button>
                    <button class="btn btn-success set-mongo">Set rules from MongoDB</button>--%>
                </div>

                <div class="btn-group">
                    <label class="btn btn-default">Get:</label>
                    <button class="btn btn-primary parse-json">JSON</button>
                    <button class="btn btn-primary parse-sql" data-stmt="question_mark">SQL (question mark)</button>
                    <button class="btn btn-primary parse-sql" data-stmt="numbered">SQL (numbered)</button>
                    <button class="btn btn-primary parse-sql" data-stmt="false">SQL</button>
                    <button class="btn btn-primary parse-mongo">MongoDB</button>
                </div>

                <div id="result" class="hide">
                    <h3>Output</h3>
                    <pre></pre>
                </div>
            </div>
        </div>

        <script src="Scripts/jquery.js"></script>
        <script src="Scripts/bootstrap.js"></script>
        <script src="Scripts/bootstrap-select.js"></script>
        <script src="Scripts/bootbox.js"></script>
        <script src="Scripts/bootstrap-slider.js"></script>
        <script src="Scripts/selectize.js"></script>
        <script src="Scripts/jQuery.extendext.js"></script>

        <script src="Scripts/query-builder.js"></script>

        <script>
            var rules_basic = {
                condition: 'AND',
                rules: [{
                    id: 'price',
                    operator: 'less',
                    value: 10.25
                }, {
                    condition: 'OR',
                    rules: [{
                        id: 'category',
                        operator: 'equal',
                        value: 2
                    }, {
                        id: 'category',
                        operator: 'equal',
                        value: 1
                    }]
                }]
            };

            $('#builder').queryBuilder({
                plugins: ['bt-tooltip-errors'],

                filters: [{
                    id: 'name',
                    label: 'Name',
                    type: 'string'
                },
                {
                    id: 'category',
                    label: 'Category',
                    type: 'integer',
                    input: 'select',
                    values: {
                        1: 'Books',
                        2: 'Movies',
                        3: 'Music',
                        4: 'Tools',
                        5: 'Goodies',
                        6: 'Clothes'
                    },
                    operators: ['equal', 'not_equal', 'in', 'not_in', 'is_null', 'is_not_null']
                },
                {
                    id: 'in_stock',
                    label: 'In stock',
                    type: 'integer',
                    input: 'radio',
                    values: {
                        1: 'Yes',
                        0: 'No'
                    },
                    operators: ['equal']
                },
                {
                    id: 'price',
                    label: 'Price',
                    type: 'double',
                    validation: {
                        min: 0,
                        step: 0.01
                    }
                },
                {
                    id: 'id',
                    label: 'Identifier',
                    type: 'string',
                    placeholder: '____-____-____',
                    operators: ['equal', 'not_equal'],
                    validation: {
                        format: /^.{4}-.{4}-.{4}$/
                    }
                }],

                rules: rules_basic
            });

            $('#builder').on('afterCreateRuleInput.queryBuilder', function (e, rule) {
                if (rule.filter.plugin == 'selectize') {
                    rule.$el.find('.rule-value-container').css('min-width', '200px')
                      .find('.selectize-control').removeClass('form-control');
                }
            });

            // set rules
            //$('.set').on('click', function () {
            //    $('#builder').queryBuilder('setRules', {
            //        condition: 'AND',
            //        rules: [{
            //            id: 'price',
            //            operator: 'between',
            //            value: [10.25, 15.52],
            //            flags: {
            //                no_delete: true,
            //                filter_readonly: true
            //            },
            //            data: {
            //                unit: '€'
            //            }
            //        }, {
            //            id: 'state',
            //            operator: 'equal',
            //            value: 'AK',
            //        }, {
            //            condition: 'OR',
            //            rules: [{
            //                id: 'category',
            //                operator: 'equal',
            //                value: 2
            //            }, {
            //                id: 'coord',
            //                operator: 'equal',
            //                value: 'B.3'
            //            }]
            //        }]
            //    });
            //});

            // set rules from MongoDB
            //$('.set-mongo').on('click', function () {
            //    $('#builder').queryBuilder('setRulesFromMongo', {
            //        "$and": [{
            //            "name": {
            //                "$regex": "^(?!Mistic)"
            //            }
            //        }, {
            //            "price": { "$gte": 0, "$lte": 100 }
            //        }, {
            //            "$or": [{
            //                "category": 2
            //            }, {
            //                "category": { "$in": [4, 5] }
            //            }]
            //        }]
            //    });
            //});

            // reset builder
            $('.reset').on('click', function (e) {
                $('#builder').queryBuilder('reset');
                $('#result').addClass('hide').find('pre').empty();
                e.preventDefault();
            });

            // get rules
            $('.parse-json').on('click', function (e) {
                $('#result').removeClass('hide')
                  .find('pre').html(JSON.stringify(
                    $('#builder').queryBuilder('getRules'),
                    undefined, 2
                  ));
                e.preventDefault();
            });

            $('.parse-sql').on('click', function (e) {
                var res = $('#builder').queryBuilder('getSQL', $(this).data('stmt'), false);
                $('#result').removeClass('hide')
                  .find('pre').html(
                    res.sql + (res.params ? '\n\n' + JSON.stringify(res.params, undefined, 2) : '')
                  );
                e.preventDefault();
            });

            $('.parse-mongo').on('click', function (e) {
                $('#result').removeClass('hide')
                  .find('pre').html(JSON.stringify(
                    $('#builder').queryBuilder('getMongo'),
                    undefined, 2
                  ));
                e.preventDefault();
            });


</script>
    </form>
</body>
</html>
