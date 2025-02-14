define([
    'jquery',
    'mage/translate'
], function ($, $t) {
    "use strict";

    return function () {
        $(document).ready(function () {
            $('#button_taxvat').on('click', function () {
                var mst = $('#taxvat').val().trim();
                if (!mst) {
                    alert($t("Vui lòng nhập MST!"));
                    return;
                }

                $.ajax({
                    url: "https://api.vietqr.io/v2/business/" + mst,
                    type: "GET",
                    dataType: "json",
                    beforeSend: function () {
                        $('#get-company').text($t('Đang lấy dữ liệu...'));
                    },
                    success: function (response) {
                        if (response && response.data) {
                            $('#company').val(response.data.name);
                            $('#street_1').val(response.data.address);
                        } else {
                            alert($t("Không tìm thấy thông tin doanh nghiệp!"));
                        }
                    },
                    error: function () {
                        alert($t("Lỗi khi lấy dữ liệu. Vui lòng thử lại!"));
                    },
                    complete: function () {
                        $('#get-company').text($t('Lấy thông tin'));
                    }
                });
            });
        });
    };
});
