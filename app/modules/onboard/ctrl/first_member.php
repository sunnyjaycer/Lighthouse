<?php
use Core\Utils;
use lighthouse\Community;
use lighthouse\Api;
use lighthouse\Log;
class controller extends Ctrl {
    function init() {

        if(app_site != 'app') {
            header("Location: " . app_url);
            die();
        }

        if (!isset($_SESSION['lhc']['d'])) {
            header("Location: " . app_url);
            die();
        }

        if ($this->__lh_request->is_xmlHttpRequest) {

            if(__ROUTER_PATH =='/update-contract-address'){
                $community = Community::get($_SESSION['lhc']['c_id']);
                $community->token_address = $this->getParam('token_address');
                $community->community_address = $this->getParam('community_address');
                $community->gas_address = $this->getParam('gas_address');
                $community->gas_private_key = $this->getParam('gas_private_key');
                $community->update();
                echo json_encode(array('success' => true));
                exit();
            }

            try {

                $display_name = $wallet_address = $block_chain =  '';

                if($this->hasParam('display_name') && strlen($this->getParam('display_name')) > 0)
                    $display_name = $this->getParam('display_name');
                else
                    throw new Exception("display_name:Not a valid name");

                if($this->hasParam('wallet_address') && strlen($this->getParam('wallet_address')) > 0)
                    $wallet_address = $this->getParam('wallet_address');
                else
                    throw new Exception("display_name:Please connect the wallet");

                $dao_domain = $_SESSION['lhc']['d'];
                $domain_check = Community::isExistsCommunity($dao_domain);

                if ($domain_check === FALSE) {
                    $block_chain = $_SESSION['lhc']['b'];

                    if($block_chain != 'solana') {
                        $api_response = api::addCommunity(constant(strtoupper($block_chain) . "_API"), $wallet_address, $_SESSION['lhc']['d'], $_SESSION['lhc']['d'], $_SESSION['lhc']['t'], 18, 0.0008);
                    }

                    if(isset($api_response->error)) {
                        echo json_encode(array('success' => false,'msg' =>'Your NTTs has not been created.','element' => 'display_name'));
                        exit();
                    }
                    else {

                        $community = new Community();
                        $community->dao_name = $_SESSION['lhc']['n'];
                        $community->dao_domain = $_SESSION['lhc']['d'];
                        $community->blockchain = $_SESSION['lhc']['b'];
                        $community->ticker = $_SESSION['lhc']['t'];
                        $community->wallet_adr = $wallet_address;
                        $community->display_name = $display_name;
                        /*------from api response-------*/
                        if($block_chain != 'solana') {
                            $community->token_address = $api_response->tokenAddress;
                            $community->community_address = $api_response->communityAddress;
                            $community->gas_address = $api_response->gasTankInfo->address;
                            $community->gas_private_key = $api_response->gasTankInfo->privateKey;
                        }

                        $id = $community->insert();
                        $_SESSION['lhc']['c_id'] = $id;

                        $log = new Log();
                        $log->type = 'Community';
                        $log->type_id = $id;
                        $log->action = 'create';
                        $log->c_by = $community->wallet_adr;
                        $log->insert();

                        echo json_encode(array(
                                'success' => true,
                                'url' => 'distribution',
                                'tokenAddress' => $community->token_address,
                                'symbol' => 'nt' . $community->ticker,
                                'image_url' => $community->getTickerImage(),
                                'blockchain' => $community->blockchain
                            )
                        );
                    }
                }
                else {
                    $_SESSION['lhc'] = null;
                    echo json_encode(array('success' => true, 'url' => 'first-member'));
                }

            }
            catch (Exception $e)
            {
                $msg = explode(':',$e->getMessage());
                $element = 'error-msg';
                if(isset($msg[1])){
                    $element = $msg[0];
                    $msg = $msg[1];
                }
                echo json_encode(array('success' => false,'msg'=>$msg,'element'=>$element));
            }
            exit();
        } else {

            $solana = false;
            if($_SESSION['lhc']['b'] == 'solana')
                $solana = true;

            $__page = (object)array(
                'title' => 'Fist Member',
                'dao_domain' => $_SESSION['lhc']['d'],
                'dao_name' => $_SESSION['lhc']['n'],
                'blockchain' => $_SESSION['lhc']['b'],
                'ticker' => $_SESSION['lhc']['t'],
                'solana' => $solana,
                'sections' => array(
                    __DIR__ . '/../tpl/section.first_member.php'
                ),
                'js' => array()
            );
            require_once app_template_path . '/base.php';
            exit();
        }
    }
}
?>