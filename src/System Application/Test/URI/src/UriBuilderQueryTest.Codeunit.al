// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Utilities;

using System.Utilities;
using System.TestLibraries.Utilities;

codeunit 135072 "Uri Builder Query Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        UriBuilder: Codeunit "Uri Builder";

    [Test]
    [Scope('OnPrem')]
    procedure TestDuplicateParameterKeys_KeepDuplicates()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com');

        // [When] Adding multiple query parameters with the same key and keep both
        UriBuilder.AddQueryParameter('BC is awesome', 'true', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        UriBuilder.AddQueryParameter('BC is awesome', 'false', Enum::"Uri Query Duplicate Behaviour"::"Keep All");

        // [Then] Both the query parameters are kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?BC%20is%20awesome=true&BC%20is%20awesome=false', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestDuplicateParameterKeys_KeepNew()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com');

        // [When] Adding multiple query parameters with the same key and keep new
        UriBuilder.AddQueryParameter('BC is awesome', 'true', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");
        UriBuilder.AddQueryParameter('BC is awesome', 'false', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");

        // [Then] The new parameter value is kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?BC%20is%20awesome=false', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDuplicateParameterKeys_KeepOld()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com');

        // [When] Adding multiple query parameters with the same key and keep old
        UriBuilder.AddQueryParameter('BC is awesome', 'true', Enum::"Uri Query Duplicate Behaviour"::Skip);
        UriBuilder.AddQueryParameter('BC is awesome', 'false', Enum::"Uri Query Duplicate Behaviour"::Skip);

        // [Then] The old parameter value is kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?BC%20is%20awesome=true', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDuplicateParameterKeys_Error()
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com');

        // [When] Adding multiple query parameters with the same key and error option
        UriBuilder.AddQueryParameter('BC is awesome', 'true', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        // [Then] An error is thrown when adding the second parameter
        asserterror UriBuilder.AddQueryParameter('BC is awesome', 'false', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        Assert.ExpectedError('The provided query parameter is already present in the URI.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDuplicateFlags_KeepDuplicates()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com');

        // [When] Adding multiple identical query flags with keep both option
        UriBuilder.AddQueryFlag('use experimental_1', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        UriBuilder.AddQueryFlag('use experimental_1', Enum::"Uri Query Duplicate Behaviour"::"Keep All");

        // [Then] Both the query parameters are kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?use%20experimental_1&use%20experimental_1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDuplicateFlags_KeepOld()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com');

        // [When] Adding multiple identical query flags with keep old option
        UriBuilder.AddQueryFlag('use experimental_1', Enum::"Uri Query Duplicate Behaviour"::Skip);
        UriBuilder.AddQueryFlag('use experimental_1', Enum::"Uri Query Duplicate Behaviour"::Skip);

        // [Then] Only one of the identical flags is kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?use%20experimental_1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDuplicateFlags_KeepNew()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com');

        // [When] Adding multiple identical query flags with keep new option
        UriBuilder.AddQueryFlag('use experimental_1', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");
        UriBuilder.AddQueryFlag('use experimental_1', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");

        // [Then] Only one of the identical flags is kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?use%20experimental_1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDuplicateFlags_ThrowError()
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com');

        // [When] Adding multiple identical query flags with error option
        UriBuilder.AddQueryFlag('use experimental_1', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        // [Then] An error is thrown when the second flag is added
        asserterror UriBuilder.AddQueryFlag('use experimental_1', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        Assert.ExpectedError('The provided query flag is already present in the URI.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExistingValuesAreKept_KeepBoth()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url with existing query parameters and fragment
        UriBuilder.Init('https://base.microsoft.com/somepath/?llama=130&llama=42&useOrganicFood&giraffe=0#bookmark1');

        // [When] Adding a query parameter
        UriBuilder.AddQueryParameter('dolphin', '14', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        UriBuilder.AddQueryFlag('feedAllAnimals', Enum::"Uri Query Duplicate Behaviour"::"Keep All");

        // [Then] The query parameter is added, existing query and fragments are kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://base.microsoft.com/somepath/?llama=130&llama=42&giraffe=0&dolphin=14&useOrganicFood&feedAllAnimals#bookmark1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExistingValuesAreKept_KeepNew()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url with existing query parameters and fragment
        UriBuilder.Init('https://base.microsoft.com/somepath/?llama=130&llama=42&useOrganicFood&giraffe=0#bookmark1');

        // [When] Adding a query parameter
        UriBuilder.AddQueryParameter('dolphin', '14', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");
        UriBuilder.AddQueryFlag('feedAllAnimals', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");

        // [Then] The query parameter is added, existing query and fragments are kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://base.microsoft.com/somepath/?llama=130&llama=42&giraffe=0&dolphin=14&useOrganicFood&feedAllAnimals#bookmark1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExistingValuesAreKept_KeepOld()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url with existing query parameters and fragment
        UriBuilder.Init('https://base.microsoft.com/somepath/?llama=130&llama=42&useOrganicFood&giraffe=0#bookmark1');

        // [When] Adding a query parameter
        UriBuilder.AddQueryParameter('dolphin', '14', Enum::"Uri Query Duplicate Behaviour"::Skip);
        UriBuilder.AddQueryFlag('feedAllAnimals', Enum::"Uri Query Duplicate Behaviour"::Skip);

        // [Then] The query parameter is added, existing query and fragments are kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://base.microsoft.com/somepath/?llama=130&llama=42&giraffe=0&dolphin=14&useOrganicFood&feedAllAnimals#bookmark1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExistingValuesAreKept_ThrowError()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url with existing query parameters and fragment
        UriBuilder.Init('https://base.microsoft.com/somepath/?llama=130&llama=42&useOrganicFood&giraffe=0#bookmark1');

        // [When] Adding a query parameter
        UriBuilder.AddQueryParameter('dolphin', '14', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        UriBuilder.AddQueryFlag('feedAllAnimals', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");

        // [Then] The query parameter is added, existing query and fragments are kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://base.microsoft.com/somepath/?llama=130&llama=42&giraffe=0&dolphin=14&useOrganicFood&feedAllAnimals#bookmark1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestMultipleExisting_KeepBoth()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url with existing query parameters and fragment
        UriBuilder.Init('https://base.microsoft.com/somepath/?llama=130&llama=42&useOrganicFood&useOrganicFood&feedAllAnimals&giraffe=0#bookmark1');

        // [When] Adding a query parameter
        UriBuilder.AddQueryParameter('llama', '14', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        UriBuilder.AddQueryFlag('useOrganicFood', Enum::"Uri Query Duplicate Behaviour"::"Keep All");

        // [Then] The query parameter is added, existing query and fragments are kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://base.microsoft.com/somepath/?llama=130&llama=42&llama=14&giraffe=0&useOrganicFood&useOrganicFood&feedAllAnimals&useOrganicFood#bookmark1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMultipleExisting_KeepNew()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url with existing query parameters and fragment
        UriBuilder.Init('https://base.microsoft.com/somepath/?llama=130&llama=42&useOrganicFood&useOrganicFood&feedAllAnimals&giraffe=0#bookmark1');

        // [When] Adding a query parameter
        UriBuilder.AddQueryParameter('llama', '14', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");
        UriBuilder.AddQueryFlag('useOrganicFood', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");

        // [Then] The query parameter is added, existing query and fragments are kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://base.microsoft.com/somepath/?llama=14&giraffe=0&feedAllAnimals&useOrganicFood#bookmark1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMultipleExisting_KeepOld()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url with existing query parameters and fragment
        UriBuilder.Init('https://base.microsoft.com/somepath/?llama=130&llama=42&useOrganicFood&useOrganicFood&feedAllAnimals&giraffe=0#bookmark1');

        // [When] Adding a query parameter
        UriBuilder.AddQueryParameter('llama', '14', Enum::"Uri Query Duplicate Behaviour"::Skip);
        UriBuilder.AddQueryFlag('useOrganicFood', Enum::"Uri Query Duplicate Behaviour"::Skip);

        // [Then] The query parameter is added, existing query and fragments are kept
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://base.microsoft.com/somepath/?llama=130&llama=42&giraffe=0&useOrganicFood&useOrganicFood&feedAllAnimals#bookmark1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMultipleExisting_ThrowError()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url with existing query parameters and fragment
        UriBuilder.Init('https://base.microsoft.com/somepath/?llama=130&llama=42&useOrganicFood&useOrganicFood&feedAllAnimals&giraffe=0#bookmark1');

        // [When] Adding a query parameter
        asserterror UriBuilder.AddQueryParameter('llama', '14', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        Assert.ExpectedError('The provided query parameter is already present in the URI.');

        asserterror UriBuilder.AddQueryFlag('useOrganicFood', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        Assert.ExpectedError('The provided query flag is already present in the URI.');

        // [Then] The URL is unchanged (though possibly reordered)
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://base.microsoft.com/somepath/?llama=130&llama=42&useOrganicFood&useOrganicFood&feedAllAnimals&giraffe=0#bookmark1', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExpectedEncoding_Parameters()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com/?è=éNotEncoded&%C3%A8=%C3%A9Encoded');

        // [When] Adding a query parameter that needs encoding
        UriBuilder.AddQueryParameter('è', 'éAddedNotEncoded', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        UriBuilder.AddQueryParameter('%C3%A8', '%C3%A9AddedEncoded', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        UriBuilder.AddQueryParameter('moreGarbledStuff', '&/\''"*!???%20', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        UriBuilder.AddQueryParameter('고양이', ':30&고양이', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");

        // [Then] The resulting URI has encoded query parameters
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?%C3%A8=%C3%A9NotEncoded&%C3%A8=%C3%A9Encoded' // Initial parameters
            + '&%C3%A8=%C3%A9AddedNotEncoded&%25C3%25A8=%25C3%25A9AddedEncoded' // Added parameters (the one that was already encoded should be double encoded)
            + '&moreGarbledStuff=%26%2F%5C%27%22%2A%21%3F%3F%3F%2520' // Ensure escape and special characters are encoded
            + '&%EA%B3%A0%EC%96%91%EC%9D%B4=%3A30%26%EA%B3%A0%EC%96%91%EC%9D%B4', // Ensure character that use 3 bytes are also correctly encoded
            Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExpectedODataEncoding_NonODataParameters()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com/?è=éNotEncoded&%C3%A8=%C3%A9Encoded');

        // [When] Adding OData parameters that don't include the $ sign
        UriBuilder.AddODataQueryParameter('è', 'éAddedNotEncoded');
        UriBuilder.AddODataQueryParameter('%C3%A8', '%C3%A9AddedEncoded');
        UriBuilder.AddODataQueryParameter('moreGarbledStuff', '&/\''"???%20');
        UriBuilder.AddODataQueryParameter('고양이', ':30&고양이');

        // [Then] The resulting URI has encoded query parameters (same as if using the regular non-OData function)
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/' // Initial parameters are overwritten
            + '?%C3%A8=%C3%A9AddedNotEncoded&%25C3%25A8=%25C3%25A9AddedEncoded' // Added parameters (the one that was already encoded should be double encoded)
            + '&moreGarbledStuff=%26%2F%5C%27%22%3F%3F%3F%2520' // Ensure escape and special characters are encoded
            + '&%EA%B3%A0%EC%96%91%EC%9D%B4=%3A30%26%EA%B3%A0%EC%96%91%EC%9D%B4', // Ensure character that use 3 bytes are also correctly encoded
            Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExpectedODataEncoding_ODataParameters()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com/?$top=33&%24skip=41&$filter=nothing&è=éNotEncoded&%C3%A8=%C3%A9Encoded');

        // [When] Adding OData parameters that include the $ sign
        UriBuilder.AddODataQueryParameter('$filter', 'Name eq ''&Contoso''');
        UriBuilder.AddODataQueryParameter('$expand', 'Products($filter=DiscontinuedDate eq null)');
        UriBuilder.AddODataQueryParameter('moreGarbledStuff😊', '&/\''"*!???%20');

        // [Then] The resulting URI has encoded query parameters, except the $ sign in the parameter name
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?$top=33&$skip=41' // Initial parameters
            + '&$filter=Name%20eq%20%27%26Contoso%27' // Filter
            + '&%C3%A8=%C3%A9NotEncoded&%C3%A8=%C3%A9Encoded' // Other initial parameters
            + '&$expand=Products%28%24filter%3DDiscontinuedDate%20eq%20null%29' // $ is encoded in the value
            + '&moreGarbledStuff%F0%9F%98%8A=%26%2F%5C%27%22%2A%21%3F%3F%3F%2520', // Non-OData parameter
            Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExpectedODataEncoding_ODataParametersThenFlag()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com/?$top=33&%24skip=41&$filter=nothing&è=éNotEncoded&%C3%A8=%C3%A9Encoded');

        // [When] Adding OData parameters that include the $ sign
        UriBuilder.AddODataQueryParameter('$filter', 'Name eq ''&Contoso''');
        UriBuilder.AddODataQueryParameter('$expand', 'Products($filter=DiscontinuedDate eq null)');
        UriBuilder.AddODataQueryParameter('moreGarbledStuff😊', '&/\''"*!???%20');

        // [When] Adding a flag afterwards that does not require OData encoding
        UriBuilder.AddQueryFlag('$newschemaversion');

        // [Then] The library honours the encoding of the last parameter or flag added, and hence the resulting URI has encoded query parameters, including the $ sign in the parameter name.
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?%24top=33&%24skip=41' // Initial parameters
            + '&%24filter=Name%20eq%20%27%26Contoso%27' // Filter
            + '&%C3%A8=%C3%A9NotEncoded&%C3%A8=%C3%A9Encoded' // Other initial parameters
            + '&%24expand=Products%28%24filter%3DDiscontinuedDate%20eq%20null%29' // $ is encoded in the value
            + '&moreGarbledStuff%F0%9F%98%8A=%26%2F%5C%27%22%2A%21%3F%3F%3F%2520' // Non-OData parameter
            + '&%24newschemaversion', // Flag
            Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExpectedEncoding_Flags()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com/?éNotEncoded&%C3%A9Encoded');

        // [When] Adding a flag that needs encoding
        UriBuilder.AddQueryFlag('éAddedAsNotEncoded', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        UriBuilder.AddQueryFlag(':30&고양이', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        UriBuilder.AddQueryFlag('&/\''"???%20', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        UriBuilder.AddQueryFlag('%C3%A9AddedEncoded', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");

        // [Then] The resulting URI has encoded query parameters
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?%C3%A9NotEncoded&%C3%A9Encoded' // Initial flags
            + '&%C3%A9AddedAsNotEncoded' // Added flag
            + '&%3A30%26%EA%B3%A0%EC%96%91%EC%9D%B4' // Ensure character that use 3 bytes are also correctly encoded
            + '&%26%2F%5C%27%22%3F%3F%3F%2520' // Ensure escape and special characters are encoded
            + '&%25C3%25A9AddedEncoded', // Ensure already encoded values are double encoded
            Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestOtherProtocol()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url using a protocol other than http or https
        UriBuilder.Init('ftps://microsoft.com:1234');

        // [When] Adding a query parameter
        UriBuilder.AddQueryParameter('size', '4', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");

        // [Then] The query parameter is added successfully
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('ftps://microsoft.com:1234/?size=4', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRedundantPort()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url with a redundant port (i.e. the default port for the protocol)
        UriBuilder.Init('https://whatever.bc.dynamics.azure.office.microsoft.com:443');

        // [When] Adding a query parameter
        UriBuilder.AddQueryParameter('a', 'b', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        UriBuilder.AddQueryParameter('a', 'thisIsNotShown', Enum::"Uri Query Duplicate Behaviour"::Skip);

        // [Then] The resulting URI has the right query parameter (the reduntant port is removed)
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://whatever.bc.dynamics.azure.office.microsoft.com/?a=b', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestEmptyValues()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('https://microsoft.com');

        // [When] Adding a query parameter with an empty key
        // [Then] An error is thrown
        asserterror UriBuilder.AddQueryParameter('', 'a', Enum::"Uri Query Duplicate Behaviour"::Skip);
        Assert.ExpectedError('The query parameter key cannot be empty.');
        asserterror UriBuilder.AddQueryParameter('', 'a', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");
        Assert.ExpectedError('The query parameter key cannot be empty.');
        asserterror UriBuilder.AddQueryParameter('', 'a', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        Assert.ExpectedError('The query parameter key cannot be empty.');
        asserterror UriBuilder.AddQueryParameter('', 'a', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        Assert.ExpectedError('The query parameter key cannot be empty.');

        // [When] Adding an empty query flag
        // [Then] An error is thrown
        asserterror UriBuilder.AddQueryFlag('', Enum::"Uri Query Duplicate Behaviour"::Skip);
        Assert.ExpectedError('The flag cannot be empty.');
        asserterror UriBuilder.AddQueryFlag('', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");
        Assert.ExpectedError('The flag cannot be empty.');
        asserterror UriBuilder.AddQueryFlag('', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        Assert.ExpectedError('The flag cannot be empty.');
        asserterror UriBuilder.AddQueryFlag('', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        Assert.ExpectedError('The flag cannot be empty.');

        // [When] Adding a query parameter with an empty value
        // [Then] No error is thrown and the result is as expected
        UriBuilder.AddQueryParameter('c', '', Enum::"Uri Query Duplicate Behaviour"::Skip);
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?c=', Uri.GetAbsoluteUri(), 'Unexpected URL.');

        UriBuilder.Init('https://microsoft.com');
        UriBuilder.AddQueryParameter('c', '', Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?c=', Uri.GetAbsoluteUri(), 'Unexpected URL.');

        UriBuilder.Init('https://microsoft.com');
        UriBuilder.AddQueryParameter('c', '', Enum::"Uri Query Duplicate Behaviour"::"Keep All");
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?c=', Uri.GetAbsoluteUri(), 'Unexpected URL.');

        UriBuilder.Init('https://microsoft.com');
        UriBuilder.AddQueryParameter('c', '', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?c=', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    procedure TestRemoveQueryFlagWithDuplicateAction()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A URL with query flags
        UriBuilder.Init('https://microsoft.com/?flag1&flag2');

        // [When] Removing a query flag with a specified duplicate action
        UriBuilder.RemoveQueryFlag('flag1', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");

        // [Then] The query flag is removed correctly
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?flag2', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    procedure TestRemoveQueryFlagNotFound()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A URL with query flags
        UriBuilder.Init('https://microsoft.com/?flag1&flag2');

        // [When] Removing a query flag that does not exist
        UriBuilder.RemoveQueryFlag('flag3');

        // [Then] The URL is unchanged
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?flag1&flag2', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    procedure TestRemoveQueryFlagNotFoundThrowError()
    begin
        // [Given] A URL with query flags
        UriBuilder.Init('https://microsoft.com/?flag1&flag2');

        // [When] Removing a query flag that does not exist with throw error
        asserterror UriBuilder.RemoveQueryFlag('flag3', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");

        // [Then] An error is thrown
        Assert.ExpectedError('The provided query flag is not present in the URI.');
    end;

    [Test]
    procedure TestRemoveQueryFlag()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A URL with query flags
        UriBuilder.Init('https://microsoft.com/?flag1&flag2');

        // [When] Removing a query flag
        UriBuilder.RemoveQueryFlag('flag1');

        // [Then] The query flag is removed correctly
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?flag2', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    procedure TestRemoveQueryParameterWithDuplicateAction()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A URL with query parameters
        UriBuilder.Init('https://microsoft.com/?param1=value1&param2=value2');

        // [When] Removing a query parameter with a specified duplicate action
        UriBuilder.RemoveQueryParameter('param1', 'value1', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");

        // [Then] The query parameter is removed correctly
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?param2=value2', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    procedure TestRemoveQueryParameterNotFoundThrowError()
    begin
        // [Given] A URL with query parameters
        UriBuilder.Init('https://microsoft.com/?param1=value1&param2=value2');

        // [When] Removing a query parameter that does not exist with throw error
        asserterror UriBuilder.RemoveQueryParameter('param3', 'value3', Enum::"Uri Query Duplicate Behaviour"::"Throw Error");

        // [Then] An error is thrown
        Assert.ExpectedError('The provided query parameter is not present in the URI.');
    end;

    [Test]
    procedure TestRemoveQueryParameter()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A URL with query parameters
        UriBuilder.Init('https://microsoft.com/?param1=value1&param2=value2');

        // [When] Removing a query parameter
        UriBuilder.RemoveQueryParameter('param1', 'value1');

        // [Then] The query parameter is removed correctly
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/?param2=value2', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    procedure TestRemoveQueryParameters()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A URL with multiple query parameters
        UriBuilder.Init('https://microsoft.com/?param1=value1&param2=value2');

        // [When] Removing all query parameters
        UriBuilder.RemoveQueryParameters();

        // [Then] All query parameters are removed
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com/', Uri.GetAbsoluteUri(), 'Unexpected URL.');
    end;

    [Test]
    procedure TestGetQueryFlags()
    var
        Flags: List of [Text];
    begin
        // [Given] A URL with query flags
        UriBuilder.Init('https://microsoft.com/?flag1&flag2');

        // [When] Getting query flags
        Flags := UriBuilder.GetQueryFlags();

        // [Then] The list of query flags is correct
        Assert.AreEqual(2, Flags.Count(), 'Unexpected number of flags.');
        Assert.IsTrue(Flags.Contains('flag1'), 'Flag1 not found.');
        Assert.IsTrue(Flags.Contains('flag2'), 'Flag2 not found.');
    end;

    [Test]
    procedure TestGetQueryParameters()
    var
        Params: Dictionary of [Text, List of [Text]];
    begin
        // [Given] A URL with query parameters
        UriBuilder.Init('https://microsoft.com/?param1=value1&param2=value2');

        // [When] Getting query parameters
        Params := UriBuilder.GetQueryParameters();

        // [Then] The dictionary of query parameters is correct
        Assert.AreEqual(2, Params.Count(), 'Unexpected number of parameters.');
        Assert.IsTrue(Params.ContainsKey('param1'), 'Param1 not found.');
        Assert.IsTrue(Params.ContainsKey('param2'), 'Param2 not found.');
        Assert.AreEqual('value1', Params.Get('param1').Get(1), 'Unexpected value for param1.');
        Assert.AreEqual('value2', Params.Get('param2').Get(1), 'Unexpected value for param2.');
    end;

    [Test]
    procedure TestGetQueryParameter()
    var
        ParamValues: List of [Text];
    begin
        // [Given] A URL with query parameters
        UriBuilder.Init('https://microsoft.com/?param1=value1&param2=value2');

        // [When] Getting a specific query parameter
        ParamValues := UriBuilder.GetQueryParameter('param1');

        // [Then] The value of the query parameter is correct
        Assert.AreEqual(1, ParamValues.Count(), 'Unexpected number of values.');
        Assert.AreEqual('value1', ParamValues.Get(1), 'Unexpected value.');
    end;

    [Test]
    procedure TestGetQueryParameterNotFound()
    var
        ParamValues: List of [Text];
    begin
        // [Given] A URL with query parameters
        UriBuilder.Init('https://microsoft.com/?param1=value1&param2=value2');

        // [When] Getting query parameters that do not exist
        ParamValues := UriBuilder.GetQueryParameter('param3');

        // [Then] The list of query parameters is empty
        Assert.AreEqual(0, ParamValues.Count(), 'Unexpected number of parameters.');
    end;
}