using System.Linq.Expressions;
using System.Text.RegularExpressions;
using DJDPatricio.IMS.API.Models.Result.Custom;
using DJDPatricio.IMS.API.Repository.Interface.V1;

namespace DJDPatricio.IMS.API.Helpers
{
    public static class ValidationHelper
    {
        //Functions
        private static string ExtractAllowedCharacters(string pattern)
        {
            var match = Regex.Match(pattern, @"\[(.*?)\]");
            if (!match.Success) return "unknown characters";
            var charClass = match.Groups[1].Value;
            var descriptions = new List<string>();
            var ranges = new List<char[]>();

            for (var i = 0; i < charClass.Length; i++)
            {
                if (i < charClass.Length - 2 && charClass[i + 1] == '-')
                {
                    ranges.Add([charClass[i], charClass[i + 2]]);
                    i += 2;
                }
                else
                {
                    descriptions.Add(DescribeCharacter(charClass[i]));
                }
            }
            descriptions.AddRange(ranges.Select(range => DescribeRange(range[0], range[1])));
            return string.Join(", ", descriptions);
        }
        private static string DescribeCharacter(char ch)
        {
            return ch switch
            {
                ' ' => "space",
                '.' => "dot",
                ',' => "comma",
                '#' => "hash",
                '&' => "ampersand",
                '(' => "left parenthesis",
                ')' => "right parenthesis",
                '-' => "hyphen",
                '/' => "forward slash",
                '\'' => "single quote",
                ']' => "right square bracket",
                '\\' => "backslash",
                _ => "'" + ch + "'"
            };
        }
        private static string DescribeRange(char start, char end)
        {
            return start switch
            {
                'a' when end == 'z' => "small letters",
                'A' when end == 'Z' => "capital letters",
                '0' when end == '9' => "numbers",
                _ => start + "-" + end
            };
        }
        private static ValidationProperty GetPropertyNameAndValue<T>(Expression<Func<T>> expression)
        {
            switch (expression.Body)
            {
                case MemberExpression memberExpression:
                {
                    var value = expression.Compile().Invoke();
                    return new ValidationProperty
                    {
                        Name = memberExpression.Member.Name,
                        Value = value?.ToString()
                    };
                }
                case UnaryExpression { NodeType: ExpressionType.Convert } unaryExpression:
                {
                    if (unaryExpression.Operand is MemberExpression operandExpression)
                    {
                        var value = expression.Compile().Invoke();
                        return new ValidationProperty
                        {
                            Name = operandExpression.Member.Name,
                            Value = value?.ToString()
                        };
                    }

                    break;
                }
            }

            throw new ArgumentException("Expression is not a member expression");
        }
        public static ValidationResultSet ValidateInputs(List<ValidationCollection> inputValidationCollections, IReferenceV1Repository referenceV1Repository)
        {
            var inputValidationResultSet = new ValidationResultSet();
            var errors = new List<string>();
            foreach (var inputValidationResult in FieldValidation(inputValidationCollections, referenceV1Repository).Where(row => !row.IsValid))
            {
                inputValidationResultSet.IsValid = false;
                errors.Add(inputValidationResult.Field + " - " + inputValidationResult.Message + ";" + Environment.NewLine);
            }
            var distinctStrings = errors.Distinct().ToList();
            foreach (var error in distinctStrings)
            {
                inputValidationResultSet.Message += error;
            }
            inputValidationResultSet.Message = "Invalid values:{ " + Environment.NewLine + inputValidationResultSet.Message + "}";
            return inputValidationResultSet;
        }
        public static List<ValidationResult> FieldValidation(List<ValidationCollection> inputValidationCollections, IReferenceV1Repository referenceV1Repository)
        {
            var inputValidationResults = new List<ValidationResult>();
            foreach (var input in inputValidationCollections)
            {
                var propertyInfo = GetPropertyNameAndValue(input.Field);
                var proceed = false;
                if (input.IsNullable == false)
                {
                    if (propertyInfo.Value == null)
                    {
                        inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value must not be null." });
                    }
                    else
                    {
                        proceed = true;
                    }
                }
                else
                {
                    if (propertyInfo.Value != null)
                    {
                        proceed = true;
                    }
                }

                if (proceed)
                {
                    switch (input.Action)
                    {
                        case Action.CheckDate:
                        {
                            if (input.MinDate <= input.MaxDate)
                            {
                                if (Convert.ToDateTime(propertyInfo.Value) < input.MinDate)
                                {
                                    inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be less than " + input.MinDate + "." });
                                }
                                if (Convert.ToDateTime(propertyInfo.Value) > input.MaxDate)
                                {
                                    inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be more than " + input.MaxDate + "." });
                                }
                            }
                            else
                            {
                                inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Invalid configuration of Min and Max Value." });
                            }
                            break;
                        }
                        case Action.CheckString:
                        {
                            if (input.IsEmptyStringAllowed == false && propertyInfo.Value == string.Empty)
                            {
                                inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value must not be empty string." });
                            }
                            else
                            {
                                if (input.MinLength <= input.MaxLength)
                                {
                                    if (propertyInfo.Value!.Length < input.MinLength)
                                    {
                                        inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be less than " + input.MinLength + "." });
                                    }
                                    if (propertyInfo.Value.Length > input.MaxLength)
                                    {
                                        inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be more than " + input.MaxLength + "." });
                                    }
                                    if (input.Pattern != string.Empty)
                                    {
                                        var regex = new Regex(input.Pattern);
                                        var isValid = regex.IsMatch(propertyInfo.Value);
                                        if (!isValid)
                                        {
                                            var allowedCharacters = ExtractAllowedCharacters(input.Pattern);
                                            inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value should only contain the following characters: " + allowedCharacters + "." });
                                        }
                                    }
                                }
                                else
                                {
                                    inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Invalid configuration of Min and Max Length." });
                                }
                            }
                            break;
                        }
                        case Action.CheckInt:
                        {
                            if (input.IntMinValue <= input.IntMaxValue)
                            {
                                if (Convert.ToInt32(propertyInfo.Value) < input.IntMinValue)
                                {
                                    inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be less than " + input.IntMinValue + "." });
                                }
                                if (Convert.ToInt32(propertyInfo.Value) > input.IntMaxValue)
                                {
                                    inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be more than " + input.IntMaxValue + "." });
                                }
                            }
                            else
                            {
                                inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Invalid configuration of Min and Max Value." });
                            }
                            break;
                        }
                        case Action.CheckLong:
                        {
                            if (input.LongMinValue <= input.LongMaxValue)
                            {
                                if (long.Parse(propertyInfo.Value!) < input.LongMinValue)
                                {
                                    inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be less than " + input.LongMinValue + "." });
                                }
                                if (long.Parse(propertyInfo.Value!) > input.LongMaxValue)
                                {
                                    inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be more than " + input.LongMaxValue + "." });
                                }
                            }
                            else
                            {
                                inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Invalid configuration of Min and Max Value." });
                            }
                            break;
                        }
                        case Action.CheckDecimal:
                        {
                            if (input.DecimalMinValue <= input.DecimalMaxValue &&
                                input.DecimalMaxPrecision <= input.DecimalDefaultMaxPrecision &&
                                input.DecimalMaxScale <= input.DecimalDefaultMaxScale)
                            {
                                if (Convert.ToDecimal(propertyInfo.Value) < input.DecimalMinValue)
                                {
                                    inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be less than " + input.DecimalMinValue + "." });
                                }
                                if (Convert.ToDecimal(propertyInfo.Value) > input.DecimalMaxValue)
                                {
                                    inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value can't be more than " + input.DecimalMaxValue + "." });
                                }

                                //Check Precision & Scale
                                var decimalValue = Convert.ToDecimal(propertyInfo.Value!.Replace(",", ""));
                                var decimalString = decimalValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
                                if (input.DecimalMaxPrecision != 0)
                                {
                                    var precision = decimalString.Replace(".", "").Length;
                                    if (precision > input.DecimalMaxPrecision)
                                    {
                                        inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value exceeds the maximum decimal precision (" + input.DecimalMaxPrecision + ")." });
                                    }

                                }
                                if (input.DecimalMaxScale != 0)
                                {
                                    var scale = decimalString.Contains('.') ? decimalString.Length - decimalString.IndexOf('.') - 1 : 0;
                                    if (scale > input.DecimalMaxScale)
                                    {
                                        inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Value exceeds the maximum decimal scale (" + input.DecimalMaxScale + ")." });
                                    }
                                }
                            }
                            else
                            {
                                inputValidationResults.Add(new ValidationResult { IsValid = false, Field = propertyInfo.Name, Message = "Invalid configuration of Min and Max Value." });
                            }
                            break;
                        }

                        //Static Data
                        case Action.StaticData.AttachmentType:
                        {
                            if (long.Parse(propertyInfo.Value!) != StaticDataHelper.AttachmentType.Individual.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.AttachmentType.Partner.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.AttachmentType.GroupPolicyCopy.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.AttachmentType.GroupDeclarationFile.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.AttachmentType.Payments.Id)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.StaticData.ClaimsStatus:
                        {
                            if (long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.Reported.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.PendingRequirements.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.Processing.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ForApprovalSectionHead.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ForApprovalClaimsDeptHead.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ForInsurerApproval.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ApprovedByInsurer.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ForPaymentProcessing.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ReadyForRelease.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.Settled.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.Denied.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.PendingReimbursement.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.Reimbursed.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ForExGratiaProcessing.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ExGratiaForApprovalClaimsDeptHead.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ExGratiaForApprovalInsurer.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ExGratiaForApprovalAccountingDeptHead.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ForExGratiaPaymentProcessing.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ReadyForReleaseExGratia.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.SettledExGratia.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.Cancelled.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.ReactivatedForPayout.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.ClaimsStatus.Archived.Id)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.StaticData.CocStatus:
                        {
                            if (long.Parse(propertyInfo.Value!) != StaticDataHelper.CocStatus.Active.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.CocStatus.Claimed.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.CocStatus.Expired.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.CocStatus.Cancelled.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.CocStatus.Void.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.CocStatus.Inactive.Id)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.StaticData.PaymentStatus:
                        {
                            if (long.Parse(propertyInfo.Value!) != StaticDataHelper.PaymentStatus.FullyPaid.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PaymentStatus.Unpaid.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PaymentStatus.PartiallyPaid.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PaymentStatus.Cancelled.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PaymentStatus.Overpaid.Id)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.StaticData.Platforms:
                        {
                            if (long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.SMS.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.FWCMobileApp.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.IClick30.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.PeraLinkApp.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.J6WPlatform.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.BizmotoPlatform.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.TagcashPlatform.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.MasterConnoisseursFromHome.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.MCMicrosite.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.Website24K.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.EMasterConnoisseursApp.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.ETapKiosk.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.CMS2.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.IMS2.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.MultiSysPlatform.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.ActionAble.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.CMSRapido.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.Togetech1.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.FortunePay.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.Togetech2.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.IVAPlatform.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.GCash.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.ProtectNow.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.CebXInsurance.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.CebOnTheGo.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.IClick3Qgen.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.Platforms.IMS3.Id)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }

                            break;
                        }
                        case Action.StaticData.PolicyBookingStatus:
                        {
                            if (long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyBookingStatus.Approved.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyBookingStatus.Disapproved.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyBookingStatus.Pending.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyBookingStatus.Declined.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyBookingStatus.Quoted.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyBookingStatus.Draft.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyBookingStatus.AutoApproved.Id)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }

                            break;
                        }
                        case Action.StaticData.PolicyType:
                        {
                            if (long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyType.Individual.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyType.Partner.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.PolicyType.Group.Id)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }

                            break;
                        }
                        case Action.StaticData.SelectionType:
                        {
                            if (long.Parse(propertyInfo.Value!) != StaticDataHelper.SelectionType.ValidIdType.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.SelectionType.Relationship.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.SelectionType.AccountType.Id &&
                                long.Parse(propertyInfo.Value!) != StaticDataHelper.SelectionType.PaymentOption.Id)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }

                            break;
                        }

                        //Reference Data
                        case Action.ReferenceData.Agents:
                        {
                            var referenceResult = referenceV1Repository.GetAgents(long.Parse(propertyInfo.Value!), null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.Approvers:
                        {
                            var referenceResult = referenceV1Repository.GetApprovers(long.Parse(propertyInfo.Value!), null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.Benefits:
                        {
                            var referenceResult = referenceV1Repository.GetBenefits(long.Parse(propertyInfo.Value!), null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.Clients:
                        {
                            var referenceResult = referenceV1Repository.GetClients(long.Parse(propertyInfo.Value!), null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.Deductibles:
                        {
                            var referenceResult = referenceV1Repository.GetDeductibles(long.Parse(propertyInfo.Value!), null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.DistributionChannel:
                        {
                            var referenceResult = referenceV1Repository.GetDistributionChannel(long.Parse(propertyInfo.Value!), null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.Partners:
                        {
                            var referenceResult = referenceV1Repository.GetPartners(long.Parse(propertyInfo.Value!), null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.ProductBenefits:
                        {
                            var referenceResult = referenceV1Repository.GetProductBenefits(long.Parse(propertyInfo.Value!), null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.ProductCategory:
                        {
                            var referenceResult = referenceV1Repository.GetProductCategory(long.Parse(propertyInfo.Value!), null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.ProductDeductibles:
                        {
                            var referenceResult = referenceV1Repository.GetProductDeductibles(long.Parse(propertyInfo.Value!), null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.ProductPremium:
                        {
                            var referenceResult = referenceV1Repository.GetProductPremium(long.Parse(propertyInfo.Value!), null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.Products:
                        {
                            var referenceResult = referenceV1Repository.GetProducts(long.Parse(propertyInfo.Value!), null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.PromoManagers:
                        {
                            var referenceResult = referenceV1Repository.GetPromoManagers(long.Parse(propertyInfo.Value!), null, null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.PromoOfficers:
                        {
                            var referenceResult = referenceV1Repository.GetPromoOfficers(long.Parse(propertyInfo.Value!), null, null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.Providers:
                        {
                            var referenceResult = referenceV1Repository.GetProviders(long.Parse(propertyInfo.Value!), null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.SalesManagers:
                        {
                            var referenceResult = referenceV1Repository.GetSalesManagers(long.Parse(propertyInfo.Value!), null, null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.SelectionList:
                        {
                            var referenceResult = referenceV1Repository.GetSelectionList(long.Parse(propertyInfo.Value!), null, input.SelectionTypeId).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                        case Action.ReferenceData.SubAgents:
                        {
                            var referenceResult = referenceV1Repository.GetSubAgents(long.Parse(propertyInfo.Value!), null, null).Result.Data!.ToList();
                            if (referenceResult.Count == 0)
                            {
                                inputValidationResults.Add(new ValidationResult
                                {
                                    IsValid = false,
                                    Field = propertyInfo.Name,
                                    Message = "Value is not valid."
                                });
                            }
                            break;
                        }
                    }
                }
            }
            return inputValidationResults;
        }

        //Constants
        public static class Action
        {
            public const string CheckDate = "Check Date";
            public const string CheckString = "Check String";
            public const string CheckInt = "Check Int";
            public const string CheckLong = "Check Long";
            public const string CheckDecimal = "Check Decimal";

            public static class StaticData
            {
                public const string AttachmentType = "Attachment Type";
                public const string ClaimsStatus = "Claims Status";
                public const string CocStatus = "Coc Status";
                public const string PaymentStatus = "Payment Status";
                public const string Platforms = "Platforms";
                public const string PolicyBookingStatus = "Policy Booking Status";
                public const string PolicyType = "Policy Type";
                public const string SelectionType = "Selection Type";
            }

            public static class ReferenceData
            {
                public const string Agents = "Agents";
                public const string Approvers = "Approvers";
                public const string Benefits = "Benefits";
                public const string Clients = "Clients";
                public const string Deductibles = "Deductibles";
                public const string DistributionChannel = "Distribution Channel";
                public const string Partners = "Partners";
                public const string ProductBenefits = "Product Benefits";
                public const string ProductCategory = "Product Category";
                public const string ProductDeductibles = "Product Deductibles";
                public const string ProductPremium = "Product Premium";
                public const string Products = "Products";
                public const string PromoManagers = "Promo Managers";
                public const string PromoOfficers = "Promo Officers";
                public const string Providers = "Providers";
                public const string SalesManagers = "Sales Managers";
                public const string SelectionList = "Selection List";
                public const string SubAgents = "Sub Agents";
            }
        }
        public static class RegexPatterns
        {
            public const string DateAndTimeString = @"^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$";
            public const string UtcString = @"^[+-]\d{4}$";
            public const string Alpha = "^[a-zA-Z]*$";
            public const string AlphaSpace = "^[a-zA-Z ]*$";
            public const string AlphaSlashSpace = "^[a-zA-Z/ ]*$";
            public const string AlphaNumericDash = "^[a-zA-Z0-9-]*$";
            public const string AlphaNumeric = "^[a-zA-Z0-9]*$";
            public const string AlphaNumericSpace = "^[a-zA-Z0-9 ]*$";
            public const string AlphaNumericDotDashApostrophe = "^[a-zA-Z0-9.' -]*$";
            public const string AlphaNumericSpaceDotComma = "^[a-zA-Z0-9., ]*$";
            public const string Numeric = "^[0-9]*$";
            public const string EmailAddress = @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
            public static class Custom
            {
                public const string ContactNumberPh = "^[0-9+]*$";
                public const string FullNames = "^[a-zA-Z0-9,'. -]*$";
                public const string Names = "^[a-zA-Z0-9' -]*$";
                public const string FirePropertySpace = "^[a-zA-Z0-9,'#&.() -]*$";
                public const string ClfgiSpace = "^[a-zA-Z0-9,'&. -]*$";
                public const string CmsprSpace = "^[a-zA-Z0-9,'&. -]*$";
                public const string AgentAffiliateSpace = "^[a-zA-Z0-9,'&. -]*$";
                public const string AgentAffiliateProvinceSpace = "^[a-zA-Z0-9ñ'&.() -]*$";
                public const string AgentAffiliateValidIdPresented = "^[a-zA-Z0-9/'() ]*$";
                public const string AgentAffiliateValidId = "^[a-zA-Z0-9-]*$";
            }
        }
    }
}